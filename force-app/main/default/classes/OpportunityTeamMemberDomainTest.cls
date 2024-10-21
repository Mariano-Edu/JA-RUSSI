@isTest
private class OpportunityTeamMemberDomainTest {
    
    @TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {

        Map<String, RecordType> recordTypes = new Map<String, RecordType>();
        Set<String> recordTypeTypes = new Set<String>{'Account', 'Contact'};

        Profile profile = [SELECT Id FROM Profile WHERE (Name = 'Administrador do sistema') OR (Name = 'System Administrator') LIMIT 1];
        Id roleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Atendente_de_Vendas_BC' LIMIT 1].Id;

        User user = new User(
            Alias = 'TestUser',
            Email = 'test@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test240920241005@email.com',
            profileId = profile.Id
        );
        insert user;

        atualizarRoleUsuario(user.Id, roleId);

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
    static void divideOppTeamMembersByOpportunityTest() {
        Test.startTest();
        OpportunityTeamMemberDomain.divideOppTeamMembersByOpportunity([SELECT Id, Name, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId = :[SELECT Id FROM Opportunity WHERE Name = 'Oportunidade 1' LIMIT 1].Id]);
        Test.stopTest();
    }

    @isTest
    static void checkUserRoleOnModificationTest() {

        Id opportunityId = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade 1' LIMIT 1].Id;
        User user = [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];

        OpportunityTeamMember opportunityTeamMember = new OpportunityTeamMember(
            OpportunityId = opportunityId,
            UserId = user.Id
        );

        System.runAs(user) {
            Database.SaveResult resultInsert = Database.insert(opportunityTeamMember, false);
            System.assert(!resultInsert.isSuccess());
        }
        
    }

    @Future
    private static void atualizarRoleUsuario(Id userId, Id roleId) {
        User user = new User(   
            Id = userId,
            UserRoleId = roleId
        );

        update user;
    }
}