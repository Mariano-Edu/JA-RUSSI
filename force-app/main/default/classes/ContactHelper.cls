public with sharing class ContactHelper {

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

            if (response.getStatusCode() == 200) cepResponse = (ViaCEPResponse)JSON.deserialize(response.getBody(), ViaCEPResponse.class);
        } catch (Exception e) {
            System.debug(e);
        }

        if (cepResponse != null) updateContactWithCEP(cep, cepResponse);
    }

    public static void updateContactWithCEP(String cep, ViaCEPResponse cepResponse) {
        List<Contact> contactsToUpdate = [SELECT Id, Bairro__c
                                          FROM Contact
                                          WHERE Cep__c = :cep];

        for (Contact ctt : contactsToUpdate) {
            ctt.Bairro__c = cepResponse.bairro;
            ctt.CidadeEndereco__c = cepResponse.localidade;
            ctt.UF__c = cepResponse.uf;
            ctt.Logradouro__c = cepResponse.logradouro;
        }

        update contactsToUpdate;
    }
}