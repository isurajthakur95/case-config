@isTest
public class CaseConfigWebServiceCalloutMock implements HttpCalloutMock {

    private HttpResponse response;

    public void setHttpResponse(HttpResponse response) {
        this.response = response;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('contentType', 'application/json');
        response.setStatusCode(200);
        return response;
    }

}