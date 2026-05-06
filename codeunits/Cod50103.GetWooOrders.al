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
        OrdersArray: JsonArray;
        OrderObject: JsonObject;
        OrderId: Integer;
        CustomerName: Text;
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

        OrderId: Integer;
        CustomerEmail: Text;
    begin
        OrderObject := OrderToken.AsObject();

        // Extract the order ID
        OrderObject.Get('id', TempToken);
        OrderId := TempToken.AsValue().AsInteger();

        // Extract the customer email from the billing information
        OrderObject.Get('billing', TempToken);
        ExtractCustomerEmail(TempToken, CustomerEmail);

        Message('Order ID: %1, Customer Email: %2', OrderId, CustomerEmail);
    end;

    local procedure ExtractCustomerEmail(BillingToken: JsonToken; var CustomerEmail: Text)
    var
        BillingObject: JsonObject;
        TempToken: JsonToken;
    begin
        BillingObject := BillingToken.AsObject();
        BillingObject.Get('email', TempToken);
        CustomerEmail := TempToken.AsValue().AsText();
    end;
}
