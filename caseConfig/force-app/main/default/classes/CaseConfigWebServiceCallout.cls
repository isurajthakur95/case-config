public with sharing class CaseConfigWebServiceCallout {
    
    String caseNamedCreds = 'callout:CaseConfigWebService/test';
    String methodPost = 'POST';
    String contentType = 'application/json';
    String acceptType = 'application/json';
    /**
* Sends a request to the Case Config Web Service.
* @param caseRecId The Id of the Case record.
* @return The HTTP response code.
**/
    public Integer sendRequest(String caseRecId){
        HttpRequest req = new HttpRequest();
        
        RestWebServiceCalloutHandler restHandlerObj = new RestWebServiceCalloutHandler();
        req = restHandlerObj.setHeaders(req, caseNamedCreds, methodPost, contentType, acceptType);
        CaseDataRequest requestData = new CaseDataRequest(caseRecId);
        req = restHandlerObj.setRequestBody(req, JSON.serialize(requestData));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getStatusCode();
    }
}