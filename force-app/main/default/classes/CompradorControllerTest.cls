@isTest
private class CompradorControllerTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        Map<String, RecordType> recordTypes = new Map<String, RecordType>();
        Set<String> recordTypeTypes = new Set<String>{'Account', 'Contact'};

        Profile profile = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1];

        UserRole papelGerente = [SELECT Id FROM UserRole WHERE Name = 'Gerente' LIMIT 1];
        UserRole papelDiretor = [SELECT Id FROM UserRole WHERE Name = 'Diretor Comercial' LIMIT 1];

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
            ),
            new User(
                Alias = 'user2',
                Email = 'test2@email.com',
                EmailEncodingKey = 'ISO-8859-1',
                LastName = 'User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                UserName = 'test270920241517z@email.com',
                profileId = profile.Id
            )
        };

        insert users;

        assignUserRole(users[0].Id, papelGerente.Id);
        assignUserRole(users[1].Id, papelDiretor.Id);

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
    }

    @isTest
    public static void getCompradorListByOpportunityIdTest() {
        Test.startTest();
        Test.stopTest();

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Oportunidade 1',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(1),
                AccountId = [SELECT Id FROM Account WHERE CNPJ__c = '55181736000103' LIMIT 1].Id,
                ResponsavelPeloLead__c = [SELECT Id FROM User WHERE Alias = 'user1' LIMIT 1].Id
            ),
            new Opportunity(
                Name = 'Oportunidade 2',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(2),
                Unidade__c = [SELECT Id FROM Product2 LIMIT 1].Id,
                AccountId = [SELECT Id FROM Account WHERE CNPJ__c = '55181736000103' LIMIT 1].Id,
                ResponsavelPeloLead__c = [SELECT Id FROM User WHERE Alias = 'user1' LIMIT 1].Id
            )
        };

        insert opportunities;

        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<Comprador__c> compradores = CompradorController.getCompradorListByOpportunityId(oppId);

        Assert.isFalse(compradores.isEmpty());
    }
    

    @Future
    private static void assignUserRole(Id userId, Id userRoleId) {
        User user = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];
        UserRole userRole = [SELECT Id FROM UserRole WHERE Id = :userRoleId];
        
        user.UserRoleId = userRole.Id;
        update user;
    }
}