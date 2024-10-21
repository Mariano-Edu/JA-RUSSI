public with sharing class EmpreendimentoHelper {

    @future(callout=true)
    public static void getCEPDataAsyncFuture(String cep) {
        getCEPDataAsync(cep);
    }
    
    public static void getCEPDataAsync(String cep) {
        ViaCEPResponse cepResponse = null;
        try {
            String baseURL = 'https://viacep.com.br/ws/';
            String requestURL = baseURL + cep + '/json/';
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(requestURL);
            request.setMethod('GET');
    
            HttpResponse response = http.send(request);
    
            if (response.getStatusCode() == 200) {
                cepResponse = (ViaCEPResponse)JSON.deserialize(response.getBody(), ViaCEPResponse.class);
            } else {
                System.debug('Erro: ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    
        if (cepResponse != null) {
            updateEmpreendimentoWithCEP(cep, cepResponse);
        }
    }

    public static List<EmpreendimentoResponse> getEmpreendimentosResponse() {
        List<EmpreendimentoResponse> empreendimentosResponse = new List<EmpreendimentoResponse>();

        for(Empreendimento__c e : [SELECT Id, Name FROM Empreendimento__c]) {
            empreendimentosResponse.add(new EmpreendimentoResponse(e));
        }

        return empreendimentosResponse;
    } 
    
    public static void updateEmpreendimentoWithCEP(String cep, ViaCEPResponse cepResponse) {
        List<Empreendimento__c> empreendimentosToUpdate = [SELECT Id
                                              FROM Empreendimento__c
                                              WHERE CEP__c = :cep];
    
        for (Empreendimento__c emp : empreendimentosToUpdate) {
            emp.Bairro__c = cepResponse.bairro;
            emp.Cidade__c = cepResponse.localidade;
            emp.UF__c = cepResponse.uf;
            emp.Logradouro__c = cepResponse.logradouro;
        }
    
        update empreendimentosToUpdate;
    }
}