@isTest
private class ContentDocumentControllerTest {
    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        Profile profile = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1];

        List<User> users = new List<User>{
            new User(
                Alias = 'user1',
                Email = 'test@email.com',
                EmailEncodingKey = 'ISO-8859-1',
                LastName = 'User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                UserName = 'test240920241005y@email.com',
                profileId = profile.Id
            )
        };

        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Account',
                CNPJ__c = '45246904000130',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '11',
                Phone = '12345-6789'   
            )
        };
        
        insert accounts;
        
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Oportunidade 1',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(2),
                AccountId = accounts.get(0).Id,
                ResponsavelPeloLead__c = users[0].Id
            )
        };

        insert opportunities;
    }

    @isTest
    private static void uploadFileTest() {
        String base64 = 'dGVzdGU=';
        String fileName = 'arquivo.txt';
        String fileType = 'text/plain';
        String linkEntityId = [SELECT Id FROM Documento__c LIMIT 1].Id;
        
        Test.startTest();
        Id resultId = ContentDocumentController.uploadFile(base64, fileName, linkEntityId, fileType);
        ContentDocumentLink cdl = ContentDocumentLinkSelector.buscarLinksDocumentosPorSetLinkedEntityId(new Set<Id>{linkEntityId})[0];
        Test.stopTest();
        
        System.assertNotEquals(null, resultId);
        
        ContentVersion cv = [SELECT Id, Title, PathOnClient, VersionData, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId = :resultId LIMIT 1];
        
        System.assertEquals(fileName, cv.Title);
        System.assertEquals(fileName, cv.PathOnClient);
        System.assertEquals(cv.VersionData.toString(), EncodingUtil.base64Decode(base64).toString());
        System.assertEquals(linkEntityId, cv.FirstPublishLocationId);
                
        System.assertNotEquals(null, cdl);
        System.assertEquals(linkEntityId, cdl.LinkedEntityId);
    }
}