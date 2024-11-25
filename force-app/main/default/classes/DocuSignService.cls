public class DocuSignService extends DocuSignCallout {

    private static final DocuSignService INSTANCE = new DocuSignService();
    private static final Integracao__mdt SETTINGS = Integracao__mdt.getInstance('DocuSign');
    private static final String ENDPOINT = SETTINGS.URLbase__c + SETTINGS.Version__c + SETTINGS.Endpoint__c + DocuSignRESTSettings__mdt.getInstance('DSAccountID').Value__c;
    private static final String ACCESS_TOKEN = Test.isRunningTest() ? 'Token_Test_eyb01' : DocuSignRESTUtility.getAccessToken();

    public static DocuSignService instance() {
        return INSTANCE;
    }
    
    public HttpResponse criarEnvelope(DocuSignObjects.Envelope envelope) {
        return execute('POST', '/envelopes', ENDPOINT, JSON.serialize(envelope), false, obterHeaders());
    }

    public HttpResponse updateParametroEnvelopes(String envelopeId, Map<String, Object> notificationSettings) {
        if (!Test.isRunningTest()) {
            String url = '/envelopes/' + envelopeId + '/notification';
            String requestBody = JSON.serialize(notificationSettings);
            return execute('PUT', url, ENDPOINT, requestBody, false, obterHeaders());
        }
        return null;
    }

    public HttpResponse cancelarEnvelope(String idEnvelope, String motivo){
        HttpResponse response;
        String jsonFormatado = '{"status": "voided", "voidedReason": "' + motivo +'"}';
        response = !Test.isRunningTest() ? execute('PUT', '/envelopes/' + idEnvelope, ENDPOINT, jsonFormatado, false, obterHeaders()) : NULL;

        return response;
    }

    private Map<String, String> obterHeaders(){
        Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + ACCESS_TOKEN };

        return headers;
    }
}