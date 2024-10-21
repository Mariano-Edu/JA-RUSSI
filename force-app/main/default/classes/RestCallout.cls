public abstract class RestCallout {
    private class Callout {
        public String endpoint;
        public String method;
        public String body;
        public Integer timeout;
        public Map<String, String> header;

        private Callout(Map<String, Object> callout) {
            this.endpoint = callout.containsKey('endpoint') ? (String) callout.get('endpoint') : null;
            this.method = callout.containsKey('method') ? (String) callout.get('method') : null;
            this.body = callout.containsKey('body') ? (String) callout.get('body') : null;
            this.timeout = callout.containsKey('timeout') ? (Integer) callout.get('timeout') : null;
            this.header = callout.containsKey('header') ? (Map<String, String>) callout.get('header') : null;
        }
    }

    private Callout callout;

    protected RestCallout(Map<String, Object> callout) {
        this.callout = new Callout(callout);
    }

    /**
     * Método responsável pelo envio de requisição ao serviço externo definido em
     * callout, baseado no método e cabeçalho também em callout. 
     */
    protected HttpResponse send() {
        HttpRequest request = new HttpRequest();

        if(String.isNotBlank(this.callout.endpoint)) { request.setEndpoint(this.callout.endpoint); }
        if(String.isNotBlank(this.callout.method)) { request.setMethod(this.callout.method); }
        if(String.isNotBlank(this.callout.body)) { request.setBody(this.callout.body); }
        if(this.callout.timeout != null) { request.setTimeout(this.callout.timeout); }
        if(!this.callout.header.isEmpty()) { setHeader(request); }

        return (new Http()).send(request);
    }

    private void setHeader(HttpRequest request) {
        for(String key : this.callout.header.keySet()) {
            request.setHeader(key, this.callout.header.get(key));
        }
    }
}