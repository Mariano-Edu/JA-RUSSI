public with sharing class AccountHelper {

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

        if (cepResponse != null) {
            updateAccountWithCEP(cep, cepResponse);
        }
    }

    public static void updateAccountWithCEP(String cep, ViaCEPResponse cepResponse) {
        List<Account> accountsToUpdate = [SELECT Id, Bairro__c
                                          FROM Account
                                          WHERE Cep__c = :cep];

        for (Account acc : accountsToUpdate) {
            acc.Bairro__c = cepResponse.bairro;
            acc.Cidade__c = cepResponse.localidade;
            acc.Uf__c = cepResponse.uf;
            acc.Logradouro__c = cepResponse.logradouro;
        }

        update accountsToUpdate;
    }
}