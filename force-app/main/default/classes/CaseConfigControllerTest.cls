@isTest
private class CaseConfigControllerTest {
    
    @testSetup
    static void setup() {
        // Create a Case record
        Case caseRecord = new Case(
            Subject = 'Test Subject',
            Description = 'Test Description'
        );
        insert caseRecord;
        
        // Create a Config__c record not associated with the Case record
        Config__c configRecord = new Config__c(
            Label__c = 'Config Label 1',
            Type__c = 'Test Type',
            Amount__c = 100.0
        );
        insert configRecord;
        
        Config__c configRecord2 = new Config__c(
            Label__c = 'Config Label 2',
            Type__c = 'Test Type',
            Amount__c = 200.0
        );
        insert configRecord2;
        
        // Create two Case_Config__c records associated with the Case record
        Case_Config__c caseConfig1 = new Case_Config__c(
            Label__c = 'Config Label 1',
            Case__c = caseRecord.Id);
        insert new List<Case_Config__c>{caseConfig1};
            }
    
    @isTest
    static void testGetConfigData() {
        // Call the method being tested
        Test.startTest();
        List<Config__c> result = CaseConfigController.getConfigData([SELECT Id FROM Case LIMIT 1].Id);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(1, result.size(), 'Expected number of Config__c records returned');
    }
    
    @isTest
    static void testGetCaseConfigData() {
        // Test method invocation
        Test.startTest();
        List<Case_Config__c> result = CaseConfigController.getCaseConfigData([SELECT Id FROM Case LIMIT 1].Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size(), 'Expected one Case_Config__c records');
        //System.assertNotEquals(2, result.size(), 'Not expected two Case_Config__c records');
    }
    
    @isTest
    static void testAddConfigData() {
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        // Call the addConfigData method with Config records
        Config__c configRecord2 = new Config__c(
            Label__c = 'Config Label 2',
            Type__c = 'Test Type',
            Amount__c = 200.0
        );
        List<Config__c> listConfig = new List<Config__c>();
        List<Case_Config__c> result = new List<Case_Config__c>();
        listConfig.add(configRecord2);
        
        result = CaseConfigController.addConfigData(caseId, listConfig);
        // Record should be inserted
        System.assertEquals(1, result.size());
    }
    
    @isTest
    static void testActionOnConfigData(){
        // Mock the HTTP response
        HttpCalloutMock mock = new CaseConfigWebServiceCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        CaseConfigController.actionOnConfigData([SELECT Id FROM Case LIMIT 1].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testActionOnConfigDataNotValid(){
        // Mock the HTTP response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        try{
            Test.startTest();
            CaseConfigController.actionOnConfigData([SELECT Id FROM Case LIMIT 1].Id);
            Test.stopTest();
        }catch(Exception ex){
            System.assertEquals(true, String.isNotBlank(ex.getMessage()));
        }
    }
    
    @isTest
    static void testGetCaseStatusValue(){
        Boolean result = CaseConfigController.getCaseStatusValue([SELECT Id FROM Case LIMIT 1].Id);
        System.assertEquals(true, result);
    }
}