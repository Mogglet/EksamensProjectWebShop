enumextension 50100 "Email Scenario Ext" extends "Email Scenario"
{
    // This enum extension adds custom email scenarios for the webshop application.
    value(50102; "Low Stock")
    {
        Caption = 'Low Stock Notification';
    }
    value(50104; "Order Confirmation")
    {
        Caption = 'Order Confirmation';
    }
}