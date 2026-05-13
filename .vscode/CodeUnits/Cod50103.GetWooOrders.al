codeunit 50103 "Get Woo Orders"
{
    trigger OnRun()
    var
        OrdersJson: Text;
    begin
        OrdersJson := GetOrders();
        if OrdersJson <> '' then begin
            ProcessOrders(OrdersJson);
        end
        else begin
            Message('No orders retrieved from WooCommerce.');
        end;
    end;

    /// <summary>
    /// Gets orders from woocommerce as json 
    /// </summary>
    /// <returns></returns>
    local procedure GetOrders(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: Text;
        Base64Convert: Codeunit "Base64 Convert";
        URL: Text;
        Auth: Text;
        Base64Auth: Text;
    begin
        // Set the URL for the WooCommerce REST API endpoint
        URL := 'http://localhost:81/wordpress/wp-json/wc/v2/orders';

        Auth := 'ck_aad846fcc935821ba3433e3587a3e504ab4dbee1:cs_69be980c307b38df47b018bbd198d3751a6c41ee';
        Base64Auth := Base64Convert.ToBase64(Auth);

        // Add the Authorization header with Basic Auth
        Client.DefaultRequestHeaders().Add('Authorization', 'Basic ' + Base64Auth);

        // Send the GET request to the WooCommerce API
        Client.Get(URL, Response);

        // Check if the response is successful
        if Response.IsSuccessStatusCode() then begin
            // Read the content of the response (orders data) into a text variable
            Response.Content().ReadAs(Content);
            // Return the content of the response (orders data) as text to be processed further
            exit(Content);
        end
        else begin
            // If the response is not successful, display an error message with the status code
            Error('Failed to retrieve orders. Status code: %1', Response.HttpStatusCode());
        end;
    end;

    /// <summary>
    /// Processes the retrieved orders from WooCommerce. 
    /// It reads the orders JSON, iterates through each order, 
    /// and handles them accordingly.
    /// </summary>
    /// <param name="OrdersJson"></param>
    local procedure ProcessOrders(OrdersJson: Text)
    var
        Orders: JsonArray;
        OrderToken: JsonToken;
    begin
        Orders.ReadFrom(OrdersJson);
        foreach OrderToken in Orders do begin
            HandleOrder(OrderToken);
        end;
    end;

    /// <summary>
    /// Handles an order by extracting the order ID, customer information, and line items from the order JSON token.
    /// </summary>
    /// <param name="OrderToken"></param>
    local procedure HandleOrder(OrderToken: JsonToken)
    var
        OrderObject: JsonObject;
        TempToken: JsonToken;
        Lines: JsonArray;
        LineToken: JsonToken;
        OrderConfirmationMgt: Codeunit "Order Confirmation Mgt";
        SalesHeader: Record "Sales Header";

        OrderId: Integer;
        CustomerEmail: Text;
        CustomerName: Text;
        CustomerNo: Code[20];
        SalesHeaderNo: Code[20];
    begin
        OrderObject := OrderToken.AsObject();

        // Extract the order ID
        if OrderObject.Get('id', TempToken) then
            OrderId := TempToken.AsValue().AsInteger()
        else
            Error('Order ID missing.');

        // Check if the order has already been processed
        if OrderAlreadyProcessed(OrderId) then begin
            exit;
        end;

        // Extract the customer email from the billing information
        if OrderObject.Get('billing', TempToken) then
            ExtractCustomerInfo(TempToken, CustomerEmail, CustomerName)
        else
            Error('Billing information missing.');

        CustomerNo := GetOrCreateCustomer(CustomerEmail, CustomerName);

        // Create the sales order header
        SalesHeaderNo := CreateSalesOrderHeader(CustomerNo, OrderId);

        // Get line items
        if OrderObject.Get('line_items', TempToken) then
            Lines := TempToken.AsArray()
        else
            Error('Line items missing.');

        foreach LineToken in Lines do begin
            HandleOrderLine(SalesHeaderNo, LineToken);
        end;

        // Log the processed order
        LogProcessedOrder(OrderId, SalesHeaderNo);

        // Send order confirmation email
        SalesHeader.Get(SalesHeader."Document Type"::Order, SalesHeaderNo);
        OrderConfirmationMgt.SendOrderConfirmation(SalesHeader);
    end;

    /// <summary>
    /// Handles an order line by extracting the SKU and quantity from the line item JSON token.
    /// It then checks if the item exists in the inventory and creates a sales line for the order.
    /// </summary>
    /// <param name="SalesHeaderNo"></param>
    /// <param name="LineToken"></param>
    local procedure HandleOrderLine(SalesHeaderNo: Code[20]; LineToken: JsonToken)
    var
        LineObject: JsonObject;
        TempToken: JsonToken;
        Item: Record Item;
        SalesLine: Record "Sales Line";

        SKU: Text;
        Quantity: Integer;
    begin
        LineObject := LineToken.AsObject();

        // Extract the SKU
        if LineObject.Get('sku', TempToken) then
            SKU := TempToken.AsValue().AsText()
        else
            Error('SKU missing in WooCommerce order line.');

        // Extract the quantity
        if LineObject.Get('quantity', TempToken) then
            Quantity := TempToken.AsValue().AsInteger()
        else
            Error('Quantity missing in WooCommerce order line.');

        Item.SetRange("No.", SKU);
        if Item.FindFirst() then begin
            // Create sales line
            SalesLine.Init();
            SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
            SalesLine.Validate("Document No.", SalesHeaderNo);
            SalesLine.Validate("Line No.", GetNextLineNo(SalesHeaderNo));
            SalesLine.Validate("Type", SalesLine."Type"::Item);
            SalesLine.Validate("No.", SKU);
            SalesLine.Validate("Quantity", Quantity);
            SalesLine.Insert(true);
        end
        else begin
            // If the item does not exist, log a message or handle accordingly
            Error('Item with SKU %1 not found in inventory.', SKU);
        end;
    end;

    local procedure GetNextLineNo(SalesHeaderNo: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeaderNo);
        if SalesLine.FindLast() then
            exit(SalesLine."Line No." + 10000);
        exit(10000);
    end;


    /// <summary>
    /// Finds customer information from json billing
    /// </summary>
    /// <param name="BillingToken"></param>
    /// <param name="CustomerEmail"></param>
    /// <param name="CustomerName"></param>
    local procedure ExtractCustomerInfo(BillingToken: JsonToken; var CustomerEmail: Text; var CustomerName: Text)
    var
        BillingObject: JsonObject;
        TempToken: JsonToken;
        FirstName: Text;
        LastName: Text;
    begin
        BillingObject := BillingToken.AsObject();
        // Extract the customer email from the billing information
        if BillingObject.Get('email', TempToken) then
            CustomerEmail := TempToken.AsValue().AsText();

        // Extract the customer first and last name from the billing information
        if BillingObject.Get('first_name', TempToken) then
            FirstName := TempToken.AsValue().AsText();
        if BillingObject.Get('last_name', TempToken) then
            LastName := TempToken.AsValue().AsText();
        CustomerName := FirstName + ' ' + LastName;
    end;

    /// <summary>
    /// Get customer by email if it exists or creates the customer if it does not
    /// </summary>
    /// <param name="Email"></param>
    /// <param name="Name"></param>
    /// <returns></returns>
    local procedure GetOrCreateCustomer(Email: Text; Name: Text): Code[20]
    var
        Customer: Record Customer;
    begin
        // Try to find the customer by email
        Customer.SetRange("E-Mail", Email);
        if Customer.FindFirst() then begin
            exit(Customer."No.");
        end
        else begin
            // If not found, create a new customer
            Customer.Init();
            Customer.Validate("E-Mail", Email);
            Customer.Validate("Name", Name);
            Customer.Validate("Customer Posting Group", 'EU');
            Customer.Validate("Gen. Bus. Posting Group", 'EU');
            Customer.Insert(true);
            exit(Customer."No.");
        end;
    end;

    /// <summary>
    /// Checks if order already has been processed
    /// </summary>
    /// <param name="OrderId"></param>
    /// <returns></returns>
    local procedure OrderAlreadyProcessed(OrderId: Integer): Boolean
    var
        WOL: Record "Woo Order Link";
    begin
        WOL.SetRange("Order ID", OrderId);
        exit(WOL.FindFirst());
    end;

    /// <summary>
    /// Creates a sales order header in Business Central for the given customer number and order ID.
    /// </summary>
    /// <param name="CustomerNo"></param>
    /// <param name="OrderId"></param>
    /// <returns></returns>
    local procedure CreateSalesOrderHeader(CustomerNo: Code[20]; OrderId: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("External Document No.", Format(OrderId));
        SalesHeader.Modify(true);
        exit(SalesHeader."No.");
    end;

    /// <summary>
    /// Logs the processed order in the Woo Order Link table.
    /// </summary>
    /// <param name="OrderId"></param>
    /// <param name="SalesHeaderNo"></param>
    local procedure LogProcessedOrder(OrderId: Integer; SalesHeaderNo: Code[20])
    var
        WOL: Record "Woo Order Link";
    begin
        WOL.Init();
        WOL.Validate("Order ID", OrderId);
        WOL.Validate("Sales Order No.", SalesHeaderNo);
        WOL.Insert();
    end;

}
