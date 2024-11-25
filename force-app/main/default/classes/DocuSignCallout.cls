public virtual class DocuSignCallout {

    public HttpResponse execute(String method, String apiMethod, String endpoint, String body, Boolean compressed, Map<String, String> headers){

        if (headers == null){
            headers = new Map<String, String>();
        }

        if (String.isEmpty(method) || String.isEmpty(apiMethod)){
            throw new DocuSignCalloutException('Favor o método da chamada');
        }
        return execute(createRequest(method, apiMethod, endpoint, body, compressed, headers));
    }

    public HttpResponse execute(HttpRequest request){
        System.debug(request.getBody());
        return new Http().send(request);
    }

    public HttpRequest createRequest(String method, String apiMethod, String endpoint, String body, Boolean compressed, Map<String, String> headers){

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setTimeout(120000);
        request.setEndpoint(endpoint + apiMethod);

        if (!String.isEmpty(body)){
            request.setBody(body);
        }

        if (method == 'PATCH'){
            request.setMethod('POST');
            headers.put('X-HTTP-Method-Override', 'PATCH');
        }

        for (String headerKey : headers.keySet()){
            request.setHeader(headerKey, headers.get(headerKey));
        }

        request.setCompressed(compressed);

        return request;
    }

    public class DocuSignCalloutException extends Exception{
    }
}