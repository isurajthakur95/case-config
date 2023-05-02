## Use Case
This use case requires the creation of two new objects, "Config__c" and "Case_Config__c". The first object has three fields, "Label" (Text, Unique), "Type" (Text), and "Amount" (Number), while the second object has the same fields along with a lookup to the Case object.

The use case requires the creation of two custom related lists on the Case detail page. The "Available Configs" component displays all Config records in a 3-column list and allows the user to select multiple records, which are added to the Case Configs list by pressing the "Add" button. Config records cannot be added to the Case Configs list more than once. The "Case Configs" component displays added Config records in a 3-column list and has a "Send" button, which, when pressed, sets the status of the Case to "Closed" and sends a request to an external service using a POST request. The request is in JSON format and includes the Case ID, status, and caseConfigs (which are the Config records added to the Case).

The use case requires a test coverage of at least 85% for APEX, with Apex used for DML and SOQL queries. Overall, the use case aims to enable users to add Config records to a Case without leaving the Case detail page and to send a request to an external service with the added Config records when the Case is closed.

## Task Breakdown for the Use Case
1. Creation of two new objects in Salesforce:
    a. Config__c object with fields: Label (Text, Unique), Type (Text), and Amount (Number).
    b. Case_Config__c object with fields: Label (Text, Unique), Type (Text), Amount (Number), and Case (Lookup to Case object).
2. 'Available Config' component on the Case detail page:
    a. Create a lighting web component named 'Available Config'.
    b. Create a Controller class that retrieves all Config records from the database which are not there on current case record.
    c. Use base lightning component to show data with columns, Label, Type, and Amount.
    d. Mutiselection of checkboxes should be allowed.
    e. Implement a button 'Add' to add the selected Config records to the 'Case Configs' component and save them to the database.
    f. Added selected config records should be shown without refresh in 'Case Configs'.
3. 'Case Configs' component on the Case detail page:
    a. Create a lighting web component named 'Case Configs'.
    b. Create a Controller class that retrieves all Case Config records.
    c. Use base lightning component to show data with columns, Label, Type, and Amount.
4. Implementation of "Send" button on the Case Configs component:
    a. Create a button 'Send' on 'Case Configs' component.
    b. When send button is clicked, do a callout to external system with below request format:
        {
            "caseId": "50068000005QOhbAAG",
            "status": "Closed",
            "caseConfigs": [{
                "label": "Test Label",
                "type": "Test Type",
                "amount": 10.00 }]
        }
    c. After successful response, disable adding new Config records and sending the request a second time. And also update case to closed.
6. Write test classes to achieve at least 85% test coverage for the Apex classes created above.
