public with sharing class CaseConfigWebServiceCallout {
    public Integer sendRequest(String caseRecId){
        HttpRequest req = new HttpRequest();

        CaseConfigWebServiceCalloutHandler caseConfigCallHandObj = new CaseConfigWebServiceCalloutHandler();
        req = caseConfigCallHandObj.setHeaders(req);
        req = caseConfigCallHandObj.setRequestBody(req, caseRecId);

        Http http = new Http();
        HttpResponse res = http.send(req);
        return res.getStatusCode();
    }
}