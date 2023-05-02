public with sharing class RestWebServiceCalloutHandler {
    String CONTENT_TYPE_HEADER = 'Content-Type';
    String ACCEPT_HEADER = 'Accept';
    /**
    * Sets the headers for the HTTP request.
    * @param req The HTTP request.
    * @param namedCred Named Cred
    * @param method Method:Get/POST
    * @param contentType Type to request content
    * @param acceptType Accept Type
    * @return The updated HTTP request.
    **/
    public HttpRequest setHeaders(HttpRequest req, String namedCred, String method, String contentType, String acceptType){
        req.setEndpoint(namedCred);
        req.setMethod(method);
        req.setHeader(CONTENT_TYPE_HEADER, contentType);
        req.setHeader(ACCEPT_HEADER, acceptType);
        return req;
    }

    /**
    * Sets the request body for the HTTP request.
    * @param req The HTTP request.
    * @param requestData The request data to send.
    * @return The updated HTTP request.
    **/
    public HttpRequest setRequestBody(HttpRequest req, String requestData){
        req.setBody(requestData);
        return req;
    }
}