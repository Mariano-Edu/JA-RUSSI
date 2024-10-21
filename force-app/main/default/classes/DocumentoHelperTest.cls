@isTest
private class DocumentoHelperTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        Profile profile = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1];

        User user = new User(
            Alias = 'user1',
            Email = 'test@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test240920241005y@email.com',
            profileId = profile.Id
        );

        insert user;

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
                Name = 'Oportunidade',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(1),
                AccountId = accounts.get(0).Id,
                ResponsavelPeloLead__c = user.Id
            )
        };

        insert opportunities;

        String base64 = 'dGVzdGU=';
        String fileName = 'arquivo.txt';
        String fileType = 'text/plain';
        String linkEntityId = [SELECT Id FROM Documento__c LIMIT 1].Id;

        ContentVersion cv = new ContentVersion(
            VersionData = EncodingUtil.base64Decode(base64),
            Title = filename,
            PathOnClient = filename
        );
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId,
            LinkedEntityId = linkEntityId,
            ShareType = 'V'
        );

        insert cdl;  
    }

    @isTest 
    private static void updateStatusDeletedTest() {
        

        Test.startTest();

        List<ContentDocument> cds = [SELECT Id FROM ContentDocument LIMIT 1];
        Assert.isFalse(cds.isEmpty(), 'ContentDocument não deve estar vazio');

        Id idDocumento = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cds[0].Id LIMIT 1].LinkedEntityId;
        Assert.isNotNull(idDocumento, 'Id do documento não deve estar nulo');

        List<Documento__c> documentosEntregues = [SELECT Id FROM Documento__c WHERE StatusAprovacao__c = 'Entregue'];
        Assert.areEqual(documentosEntregues.size(), 1, 'Deve haver 1 documento entregue');

        delete cds;

        Documento__c documento = [SELECT Id, StatusAprovacao__c FROM Documento__c WHERE Id = :documentosEntregues[0].Id];
        Assert.areEqual(documento.StatusAprovacao__c, 'Não Entregue', 'Status de aprovação do documento deve ser Não Entregue');

        Test.stopTest();
    }
}