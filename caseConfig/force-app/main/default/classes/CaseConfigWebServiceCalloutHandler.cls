public with sharing class CaseConfigWebServiceCalloutHandler {

    public HttpRequest setHeaders(HttpRequest req){
        req.setEndpoint('callout:CaseConfigWebService/test');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        return req;
    }

    public HttpRequest setRequestBody(HttpRequest req, String caseRecId){
        CaseDataRequest requestData = new CaseDataRequest(caseRecId);
        req.setBody(JSON.serialize(requestData));
        return req;
    }
}