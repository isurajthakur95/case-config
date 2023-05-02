public with sharing class CaseDataRequest {
    // Constructor
    public CaseDataRequest(String caseRecId){
        Case caseData = [SELECT Id, Status, (SELECT Id, Label__c, Type__c, Amount__c FROM Case_Configs__r) FROM Case WHERE Id = :caseRecId LIMIT 1];
        if(caseData != null){
            caseId = caseData.Id;
            status = ConstantUtility.CLOSED;
            CaseConfigRequest caseConfigRequestObj;
            for(Case_Config__c rec : caseData.Case_Configs__r){
                caseConfigRequestObj = new CaseConfigRequest();
                caseConfigRequestObj.label = rec.Label__c;
                caseConfigRequestObj.type = rec.Type__c;
                caseConfigRequestObj.amount = rec.Amount__c;
                caseConfigs.add(caseConfigRequestObj);
            }
        }
    }
    
    // Variables
    public string caseId;
    public string status;
    public List<CaseConfigRequest> caseConfigs = new List<CaseConfigRequest>();
    
    // Inner class
    class CaseConfigRequest{
        String label;
        String type;
        Decimal amount;
    }
}