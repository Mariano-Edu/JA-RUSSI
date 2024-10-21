@isTest
public class EmpreendimentoRestResourceTest {
    
    @isTest
    static void getEmpreendimentosTest() {
        // Prepare mock data by creating Empreendimento__c records
        Empreendimento__c emp1 = new Empreendimento__c(Name = 'Empresa A', CNPJ__c = '47416369000143');
        Empreendimento__c emp2 = new Empreendimento__c(Name = 'Empresa B', CNPJ__c = '33125178000118');
        
        // Insert records to generate valid Ids
        insert new List<Empreendimento__c>{emp1, emp2}; 
        
        // Mock the response that would be returned by EmpreendimentoHelper.getEmpreendimentosResponse
        List<EmpreendimentoResponse> mockResponse = new List<EmpreendimentoResponse>();
        mockResponse.add(new EmpreendimentoResponse(emp1));
        mockResponse.add(new EmpreendimentoResponse(emp2));
        
        // Use mocking or stubbing for the helper method if needed (depends on your framework)
        // Now simulate the REST method with a mock HTTP request
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Empreendimentos/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the REST method
        List<EmpreendimentoResponse> result = EmpreendimentoRestResource.getEmpreendimentos();
        Test.stopTest();
        
        // Assert that the returned list matches the mock data
        System.assertEquals(2, result.size());
        System.assertEquals(emp1.Id, result[0].id);
        System.assertEquals('Empresa A', result[0].razaoSocial);
        System.assertEquals(emp2.Id, result[1].id);
        System.assertEquals('Empresa B', result[1].razaoSocial);
    }
}