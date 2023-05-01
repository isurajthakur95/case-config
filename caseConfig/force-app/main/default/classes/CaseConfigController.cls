public with sharing class CaseConfigController {

    @AuraEnabled(cacheable=true)
    public static List<Config__c> getConfigData(String recordId){
        try {
            List<String> caseConfigLabels = new List<String>();
            for(Case_Config__c rec : [SELECT Label__c FROM Case_Config__c WHERE Case__c = :recordId LIMIT 50000]){
                caseConfigLabels.add(rec.Label__c);
            }
            return [
                SELECT Id, Label__c, Type__c, Amount__c
                FROM Config__c
                WHERE Label__c NOT IN :caseConfigLabels
                LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case_Config__c> getCaseConfigData(String recordId){
        try {
            return [SELECT Id, Label__c, Type__c, Amount__c, Case__r.Status FROM Case_Config__c WHERE Case__c = :recordId LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case_Config__c> addConfigData(String recordId, List<Config__c> newConfigRecs){
        try {
            List<Case_Config__c> newCaseConfigRecs = new List<Case_Config__c>();
            Case_Config__c caseConfigObj;
            for(Config__c rec : newConfigRecs){
                caseConfigObj = new Case_Config__c();
                caseConfigObj.Label__c = rec.Label__c;
                caseConfigObj.Type__c = rec.Type__c;
                caseConfigObj.Amount__c = rec.Amount__c;
                caseConfigObj.Case__c = recordId;
                newCaseConfigRecs.add(caseConfigObj);
            }
            if(!newCaseConfigRecs.isEmpty()){
                Database.insert(newCaseConfigRecs);
            }
            return newCaseConfigRecs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}