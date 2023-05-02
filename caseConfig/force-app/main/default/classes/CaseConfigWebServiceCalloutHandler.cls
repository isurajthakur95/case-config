public with sharing class CaseConfigWebServiceCalloutHandler {
    
    /**
* Sets the headers for the HTTP request.
* @param req The HTTP request.
* @return The updated HTTP request.
**/
    public HttpRequest setHeaders(HttpRequest req){
        req.setEndpoint('callout:CaseConfigWebService/test');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        return req;
    }
    
    /**
* Sets the request body for the HTTP request.
* @param req The HTTP request.
* @param caseRecId The Id of the Case record.
* @return The updated HTTP request.
**/
    public HttpRequest setRequestBody(HttpRequest req, String caseRecId){
        CaseDataRequest requestData = new CaseDataRequest(caseRecId);
        req.setBody(JSON.serialize(requestData));
        return req;
    }
}