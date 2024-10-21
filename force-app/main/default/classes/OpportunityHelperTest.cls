@isTest
private class OpportunityHelperTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        Map<String, RecordType> recordTypes = new Map<String, RecordType>();
        Set<String> recordTypeTypes = new Set<String>{'Account', 'Contact'};

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

        User user2 = new User(
            Alias = 'user2',
            Email = 'test2@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test270920241517z@email.com',
            profileId = profile.Id
        );

        insert user2;

        User diretor = new User(
            Alias = 'Diretor',
            Email = 'test2@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test300920241021z@email.com',
            profileId = profile.Id
        );

        insert diretor;

        assignPermission(diretor.Id);

        for (RecordType rt : [SELECT DeveloperName FROM RecordType WHERE SobjectType IN :recordTypeTypes]) {
            recordTypes.put(rt.DeveloperName, rt);
        }

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
            ),
            new Account(
                Name = 'Corretor 1',
                CNPJ__c = '55181736000103',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18805-6789',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '15',
                Phone = '36259-6789'   
            ),
            new Account(
                Name = 'Corretor 2',
                CNPJ__c = '35635456000102',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-0089',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '12',
                Phone = '96857-6789'   
            )
        };
        
        insert accounts;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '10155540000106'
        );

        insert empreendimento;

        Bloco__c bloco = new Bloco__c(
            Name = 'Torre A',
            Empreendimento__c = empreendimento.Id
        );

        insert bloco;

        Product2 unidade = new Product2(
            Name = 'Unidade',
            Bloco__c = bloco.Id,
            NumeroDaUnidade__c = 1
        );

        insert unidade;

        List<Contact> corretores = new List<Contact>{
            new Contact(
                FirstName = 'Corretor',
                LastName = 'A',
                RecordTypeId = recordTypes.get('Corretor').Id,
                AccountId = accounts.get(1).Id,
                Celular__c = '36251-6363',
                DDDCelular__c = '11',
                DDICelular__c = 'Brasil (+55)',
                Phone = '78747-5252',
                DDDTelefone__c = '21',
                DDITelefone__c = 'Brasil (+55)'
            ),
            new Contact(
                FirstName = 'Corretor',
                LastName = 'B',
                RecordTypeId = recordTypes.get('Corretor').Id,
                AccountId = accounts.get(1).Id,
                Celular__c = '85856-6363',
                DDDCelular__c = '11',
                DDICelular__c = 'Brasil (+55)',
                Phone = '74145-3524',
                DDDTelefone__c = '21',
                DDITelefone__c = 'Brasil (+55)'
            )
        };
    
        insert corretores;
        
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Oportunidade 1',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(1),
                AccountId = accounts.get(1).Id,
                ResponsavelPeloLead__c = user.Id
            ),
            new Opportunity(
                Name = 'Oportunidade 2',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(2),
                Unidade__c = unidade.Id,
                AccountId = accounts.get(0).Id,
                Corretor__c = corretores.get(0).Id,
                ResponsavelPeloLead__c = user.Id
            )
        };

        insert opportunities;
    }

    @isTest
    public static void validateOpportunitiesTest() {

        Opportunity duplicada = [SELECT Unidade__c, Corretor__c, AccountId, ResponsavelPeloLead__c FROM Opportunity WHERE Unidade__c != null AND Corretor__c != null AND AccountId != null AND ResponsavelPeloLead__c != null LIMIT 1];

        Id unidadeId = duplicada.Unidade__c;
        Id accountId = duplicada.AccountId;
        Id corretorId = duplicada.Corretor__c;
        Id responsavelId = duplicada.ResponsavelPeloLead__c;
        
        Id corretorUnicoId = [SELECT Id FROM Contact WHERE RecordTypeId != null AND Id != :corretorId LIMIT 1].Id;
        Id responsavelUnicoId = [SELECT Id, isActive, Name FROM User WHERE Id != :duplicada.ResponsavelPeloLead__c AND isActive = true AND UserName = 'test270920241517z@email.com' LIMIT 1].Id;

        Opportunity opportunity = new Opportunity(
            Name = 'Oportunidade 3',
            StageName = 'Proposta',
            CloseDate = System.today().addMonths(1),
            Unidade__c = unidadeId,
            AccountId = accountId,
            Corretor__c = corretorId,
            ResponsavelPeloLead__c = responsavelId
        );

        Test.startTest();

        Database.SaveResult resultInsert = Database.insert(opportunity, false);
        System.assert(!resultInsert.isSuccess(), 'Expected the opportunity insertion to fail, but it succeeded.');

        opportunity.Corretor__c = corretorUnicoId;
        opportunity.ResponsavelPeloLead__c = responsavelUnicoId;
        insert opportunity;

        opportunity.Corretor__c = duplicada.Corretor__c;
        Database.SaveResult resultUpdate = Database.update(opportunity, false);
        Assert.isFalse(resultUpdate.isSuccess());

        Test.stopTest();
    }

    @isTest 
    public static void updateOpportunityclosedLostTest() {
        User user = [SELECT Id FROM User WHERE Alias='Diretor' LIMIT 1];
        Test.startTest();

        Opportunity oportunidade = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Proposta' LIMIT 1];

        oportunidade.StageName = 'Fechado e Perdido';
        oportunidade.MotivoPerda__c = 'Proposta Rejeitada';
        oportunidade.SubmotivoPerda__c = 'Mudança de Preferência';
        Test.stopTest();

        System.runAs(user) {
            update oportunidade;
        }
    }

    @isTest
    public static void validateDocTest() {

        Opportunity oportunidade = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        oportunidade.StageName = 'Análise Jurídica';
        update oportunidade;
    
        Id compradorId = [SELECT Id FROM Comprador__c WHERE Oportunidade__c = :oportunidade.Id LIMIT 1].Id;
        Documento__c documento = [SELECT Id, StatusAprovacao__c FROM Documento__c WHERE Comprador__c = :compradorId LIMIT 1];
        
        Test.startTest();

        documento.StatusAprovacao__c = 'Entregue';
        Database.SaveResult updateDocErro = Database.update(documento, false);
        Assert.isFalse(updateDocErro.isSuccess(), 'Documento não pode ser marcado como entregue sem possuir um anexo');

        anexarDocumento(documento.Id);
        documento.StatusAprovacao__c = 'Entregue';
        Database.SaveResult updateDocSucesso = Database.update(documento, false);
        Assert.isTrue(updateDocSucesso.isSuccess(), 'Deve ser possível marcar documento como entregue ao possuir um anexo');
        
        oportunidade.StageName = 'Aprovação';
        Database.SaveResult updateOppErro = Database.update(oportunidade, false);
        Assert.isFalse(updateOppErro.isSuccess(), 'A oportunidade não pode avançar para a fase de aprovação porque existem documentos entregues que não estão aprovados');
        
        documento.StatusAprovacao__c = 'Aprovado';
        update documento;
        oportunidade.StageName = 'Aprovação';
        Database.SaveResult updateOppSucesso = Database.update(oportunidade, false);
        Assert.isTrue(updateOppSucesso.isSuccess(), 'A oportunidade deve avançar para a fase de aprovação');
        
        Test.stopTest();
    }

    @Future
    private static void assignPermission(Id userId) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Diretor_Comercial' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
    }

    private static void anexarDocumento(Id linkedEntityId) {
        String base64 = 'dGVzdGU=';
        String fileName = 'arquivo.txt';
        String fileType = 'text/plain';

        ContentVersion cv = new ContentVersion(
            VersionData = EncodingUtil.base64Decode(base64),
            Title = filename,
            PathOnClient = filename
        );
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId,
            LinkedEntityId = linkedEntityId,
            ShareType = 'V'
        );

        insert cdl;  
    }
}