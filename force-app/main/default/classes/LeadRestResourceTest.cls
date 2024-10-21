@isTest
public with sharing class LeadRestResourceTest {
    @TestSetup
    static void makeData(){
        Lead teste = new Lead(
            LastName = 'TesteSetup',
            Company = 'TesteCompanySetup',
            LeadSource = 'Google Ads',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '15',
            Phone = '18845-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '15',
            Celular__c = '12845-6789',
            MidiaAtual__c = 'Facebook Ads',
            Email= 'testeSetup@gmail.com',
            Status = 'New'
        );
        
        insert teste;
    }
    
    @IsTest
    static void testDoPostPositivo(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/aprexrest/Lead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<Lead> leads = new List<Lead>();
        Lead teste = new Lead(
            LastName = 'Teste',           
            Email = 'testecamposintsite5@agencia.com',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Google Ads',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18345-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-6789',
            Status = 'New'
        );
        leads.add(teste);

        Test.startTest();
            LeadRestResource.doPost(leads);
            Lead lead = [SELECT Id, Name, Email, LeadSource, Celular__c, Status FROM Lead WHERE Email =:teste.Email];
        Test.stopTest();

        system.assertEquals('Teste', lead.Name);
        system.assertEquals('testecamposintsite5@agencia.com', lead.Email);
        system.assertEquals('Google Ads', lead.LeadSource);
        system.assertEquals('18845-6789', lead.Celular__c);
        system.assertEquals('Contacting', lead.Status);
    }

    @IsTest
    static void testDoPostMissingFields(){
     Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/aprexrest/Lead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<Lead> leads = new List<Lead>();
        Lead teste = new Lead(
            LeadSource = 'Google Ads',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '17',      
            Celular__c = '99999-9904',
            Status = 'New'
        );
        leads.add(teste);

        try {
            LeadRestResource.doPost(leads);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        res = RestContext.response;

        Assert.isNotNull(res);
        Assert.isNull(res.responseBody);
        
        // String actual = res.responseBody.toString();
        // String expected = '"REQUIRED_FIELD_MISSING: Required fields are missing: [LastName]"';
         
        //  System.assertEquals(actual, expected);
        //  System.assertEquals(400,res.statusCode);

     Test.stopTest(); 
    }

    @isTest
    static void testDoPostDuplicateFieldOnRequestBody(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/aprexrest/Lead/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<Lead> leads = new List<Lead>();
        Lead teste = new Lead(
            LastName = 'Teste',
            Company = 'TesteCompany',
            LeadSource = 'Google Ads',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18895-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18645-6789',
            Email= 'teste@gmail.com',
            Status = 'New'
        );
        
        leads.add(teste);

        Lead teste2 = new Lead(
            LastName = 'Teste',
            Company = 'TesteCompany',
            LeadSource = 'Google Ads',
            Email= 'teste@gmail.com',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '19045-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18045-6789',
            Status = 'New'
        );
        leads.add(teste2);

         LeadRestResource.doPost(leads);
         res = RestContext.response;


         System.assertEquals(400,res.statusCode);
    }

    @isTest
    static void testGetRecordId() {
        Test.startTest();
        Assert.isTrue(LeadRestResource.getRecordId().size() == 2);
        Test.stopTest();
    }
}