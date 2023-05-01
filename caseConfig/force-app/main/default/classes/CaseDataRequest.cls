public with sharing class CaseDataRequest {
    public CaseDataRequest(String caseRecId){
        Case caseData = [SELECT Id, Status, (SELECT Id, Label__c, Type__c, Amount__c FROM Case_Configs__r) FROM Case WHERE Id = :caseRecId LIMIT 1];
        if(caseData != null){
            System.debug(JSON.serialize(caseData));
            caseId = caseData.Id;
            status = 'Closed';
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
    public string caseId;
    public string status;
    public List<CaseConfigRequest> caseConfigs = new List<CaseConfigRequest>();

    class CaseConfigRequest{
        String label;
        String type;
        Decimal amount;
    }
}