public class ViaCepService {
    public class Address {
        public String cep;
        public String logradouro;
        public String complemento;
        public String bairro;
        public String localidade;
        public String uf;
        public String unidade;
        public String ibge;
        public String gia;
    }

    @future(callout=true)
    public static void getAddress(String cep, Id leadId) {
        String url = 'https://viacep.com.br/ws/' + cep + '/json/';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Address address = (Address) JSON.deserialize(response.getBody(), Address.class);
            if (address != null) {
                Lead lead = [SELECT Id, Street, City, UF__c, CEP__c , Bairro__c  FROM Lead WHERE Id = :leadId LIMIT 1];
                lead.Street = address.logradouro;
                lead.City = address.localidade;
                lead.UF__c = address.uf;
                lead.CEP__c = address.cep;
                lead.Bairro__c = address.bairro;
                update lead;
            }
        }
    }
}