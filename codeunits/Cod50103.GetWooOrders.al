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

        Auth := 'ck_7f48a3cb38c0f504cca75648fb0ec5a74c5ac2f5:cs_9cb6377ea3ccb94e643fc8f69721de08d973d2c1';
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
            Message('Failed to retrieve orders. Status code: %1', Response.HttpStatusCode());
        end;
    end;

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

    local procedure HandleOrder(OrderToken: JsonToken)
    var
        OrderObject: JsonObject;
        TempToken: JsonToken;
        Lines: JsonArray;
        LineToken: JsonToken;

        OrderId: Integer;
        CustomerEmail: Text;
        CustomerName: Text;
        CustomerNo: Code[20];
    begin
        OrderObject := OrderToken.AsObject();

        // Extract the order ID
        OrderObject.Get('id', TempToken);
        OrderId := TempToken.AsValue().AsInteger();

        // Check if the order has already been processed
        if OrderAlreadyProcessed(OrderId) then begin
            exit;
        end;

        // Extract the customer email from the billing information
        OrderObject.Get('billing', TempToken);
        ExtractCustomerInfo(TempToken, CustomerEmail, CustomerName);
        CustomerNo := GetOrCreateCustomer(CustomerEmail, CustomerName);

        // Get line items
        OrderObject.Get('line_items', TempToken);
        Lines := TempToken.AsArray();
        foreach LineToken in Lines do begin
            HandleOrderLine(LineToken);
        end;
    end;

    /// <summary>
    /// Handles an order line by extracting the SKU and quantity from the line item JSON token.
    /// </summary>
    /// <param name="LineToken"></param>
    local procedure HandleOrderLine(LineToken: JsonToken)
    var
        LineObject: JsonObject;
        TempToken: JsonToken;

        SKU: Text;
        Quantity: Integer;
    begin
        LineObject := LineToken.AsObject();

        // Extract the SKU
        LineObject.Get('sku', TempToken);
        SKU := TempToken.AsValue().AsText();

        // Extract the quantity
        LineObject.Get('quantity', TempToken);
        Quantity := TempToken.AsValue().AsInteger();

        Message('Order Line - SKU: %1, Quantity: %2', SKU, Quantity);
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
            Customer.Insert(true);
            Customer.Validate("E-Mail", Email);
            Customer.Validate("Name", Name);
            Customer.Modify(True);
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

    local procedure CreateSalesOrder(OrderId: Integer; CustomerNo: Code[20]; OrderDate: Date)
    var
        SalesOrder: Record "Sales Header";
        WOL: Record "Woo Order Link";
    begin
    end;
}
