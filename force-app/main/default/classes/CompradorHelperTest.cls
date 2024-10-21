@isTest
private class CompradorHelperTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        Map<String, RecordType> recordTypes = new Map<String, RecordType>();
        Set<String> recordTypeTypes = new Set<String>{'Account', 'Contact'};

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
                ResponsavelPeloLead__c = users[0].Id
            ),
            new Opportunity(
                Name = 'Oportunidade 2',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(2),
                Unidade__c = unidade.Id,
                AccountId = accounts.get(0).Id,
                Corretor__c = corretores.get(0).Id,
                ResponsavelPeloLead__c = users[0].Id
            )
        };

        insert opportunities;
    }

    @isTest
    private static void getEstadoCivilTest() {
        Id pfRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaFisicaPF' LIMIT 1].Id;

        Test.startTest();

        Account conjuge = new Account(
            FirstName = 'Conjuge',
            LastName = 'Teste',
            CPF__c = '11122233396',
            DDICelular__c = null,
            DDITelefone__c = null,
            RecordTypeId = pfRecordTypeId
        );
        insert conjuge;

        Account conjugeDuplicado = new Account(
            FirstName = 'Conjuge',
            LastName = 'Teste',
            CPF__c = '25498268505',
            DDICelular__c = null,
            DDITelefone__c = null,
            RecordTypeId = pfRecordTypeId
        );
        insert conjugeDuplicado;

        Account contaPf = new Account(
            FirstName = 'Conta PF',
            LastName = 'Teste',
            CPF__c = '10020030088',
            DDICelular__c = null,
            DDITelefone__c = null,
            RecordTypeId = pfRecordTypeId,
            Conjuge__pc = conjuge.Id
        );

        insert contaPf;

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Proposta',
            CloseDate = Date.today().addDays(1),
            AccountId = contaPf.Id
        );

        insert oportunidade;

        List<Comprador__c> compradores = [SELECT Id, TipoParticipante__c FROM Comprador__c WHERE Oportunidade__c = :oportunidade.Id ORDER BY TipoParticipante__c]; 

        Assert.areEqual(2, compradores.size(), 'Deve haver 2 compradores');
        Assert.areEqual('Cônjuge/Companheiro', compradores.get(1).TipoParticipante__c, 'Tipo de participante deve ser Cônjuge/Companheiro');
        Assert.areEqual('Comprador', compradores.get(0).TipoParticipante__c, 'Tipo de participante deve ser Comprador');

        Comprador__c comprador = new Comprador__c(
            Oportunidade__c = oportunidade.Id,
            Conta__c = conjugeDuplicado.Id,
            TipoParticipante__c = 'Cônjuge/Companheiro'
        );

        Database.SaveResult resultInsert = Database.insert(comprador, false);
        System.assert(!resultInsert.isSuccess(), 'Não pode inserir mais de 2 conjuges por oportunidade');

        comprador.TipoParticipante__c = 'Comprador';
        resultInsert = Database.insert(comprador, false);
        System.Assert(resultInsert.isSuccess(), 'Deve inserir comprador com sucesso');

        comprador.TipoParticipante__c = 'Cônjuge/Companheiro';
        Database.SaveResult resultUpdate = Database.update(comprador, false);
        Assert.isFalse(resultUpdate.isSuccess(), 'Não pode possuir mais de 2 conjuges por oportunidade');

        Test.stopTest();
    }

}