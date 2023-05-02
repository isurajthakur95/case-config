public with sharing class CaseConfigController {
    
    /*
* Returns a list of Config__c records that are not associated with the Case__c provided.
* @param recordId: Id of the Case__c record to check against.
* @return List of Config__c records.
*/
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
            // Log the error message or return a specific error message for the user.
            throw throwException(ConstantUtility.CONFIG_DATA_RET_ERR);
        }
    }
    
    /*
* Returns a list of Case_Config__c records associated with the Case__c provided.
* @param recordId: Id of the Case__c record to retrieve records for.
* @return List of Case_Config__c records.
*/
    @AuraEnabled
    public static List<Case_Config__c> getCaseConfigData(String recordId){
        try {
            return [SELECT Id, Label__c, Type__c, Amount__c, Case__r.Status FROM Case_Config__c WHERE Case__c = :recordId LIMIT 50000];
        } catch (Exception e) {
            // Log the error message or return a specific error message for the user.
            throw throwException(ConstantUtility.CASECONFIG_DATA_RET_ERR);
        }
    }
    
    /**
* Adds new Case_Config records to a Case record.
* 
* @param recordId  The Id of the Case record to add the new records to.
* @param newConfigRecs  A list of Config__c records to be added as new Case_Config records.
* @return  A list of Case_Config records that were added to the Case.
* @throws AuraHandledException if there is any exception during the execution.
*/
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
            throw throwException(ConstantUtility.CASECONFIG_DATA_ADD_ERR + e.getMessage());
        }
    }
    
    /**
* Performs an action on the Case_Config records associated with a Case record.
* 
* @param recordId  The Id of the Case record to perform the action on.
* @throws AuraHandledException if there is any exception during the execution.
*/
    @AuraEnabled
    public static void actionOnConfigData(String recordId){
        try {
            CaseConfigWebServiceCallout calloutObject = new CaseConfigWebServiceCallout();
            Integer responseCode = calloutObject.sendRequest(recordId);
            if(responseCode != 200){
                throw new AuraHandledException(ConstantUtility.CALLOUT_FAILED_ERR + responseCode);
            }else{
                setCaseToClosed(recordId);
            }
        } catch (Exception e) {
            throw throwException(ConstantUtility.CASECONFIG_DATA_SEND_ERR + e.getMessage());
        }
    }
    
    /**
* Throws a custom AuraHandledException with the given message.
* 
* @param message  The message to be included in the exception.
* @return  The AuraHandledException object.
*/
    static AuraHandledException throwException(String message){
        AuraHandledException obj = new AuraHandledException(ConstantUtility.FAILED);
        obj.setMessage(message);
        return obj;
    }
    
    /**
* Sets the Case record to Closed.
* @param recordId The Id of the Case record.
**/
    static void setCaseToClosed(String recordId){
        Case caseObj = new Case();
        caseObj.Id = recordId;
        caseObj.Status = ConstantUtility.CLOSED;
        update caseObj;
    }
    
    /**
* Returns the status of the Case record.
* @param recordId The Id of the Case record.
* @return The status of the Case record.
**/
    @AuraEnabled
    public static boolean getCaseStatusValue(String recordId){
        try {
            Case caseObj = [SELECT Id,Status FROM Case WHERE Id = :recordId];
            return caseObj.Status != ConstantUtility.CLOSED;
        } catch (Exception e) {
            throw throwException(e.getMessage());
        }
    }
}