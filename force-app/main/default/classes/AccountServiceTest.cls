@isTest
private class AccountServiceTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        Id pjRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaJuridicaPJ' LIMIT 1].Id;

        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Conta teste1',
                RecordTypeId = pjRecordTypeId,
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                Cep__c = '01001-000',
                DDICelular__c = null,
                DDITelefone__c = null
            ),

            new Account(
                Name = 'Conta teste2',
                RecordTypeId = pjRecordTypeId,
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                Cep__c = '01001-000',
                DDICelular__c = null,
                DDITelefone__c = null,
                DataDeNascimento__c = Date.today()
            ),

            new Account(
                Name = 'Conta teste3',
                RecordTypeId = pjRecordTypeId,
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                Cep__c = '01001-000',
                DDICelular__c = null,
                DDITelefone__c = null
            ),

            new Account(
                Name = 'Conta teste4',
                RecordTypeId = pjRecordTypeId,
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                Cep__c = '01001-000',
                DDICelular__c = null,
                DDITelefone__c = null
            )
        };

        insert accounts;

        User user = new User(
            Alias = 'TestUser',
            Email = 'test@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test240920241005@email.com',
            profileId = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1].Id
        );

        insert user;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade 1',
            StageName = 'Proposta',
            CloseDate = System.today().addMonths(1),
            AccountId = accounts.get(3).Id,
            ResponsavelPeloLead__c = user.Id
        );

        insert opp;

        AnaliseDeCredito__c analise = new AnaliseDeCredito__c(
            Oportunidade__c = opp.Id
        );

        insert analise;

        insert new List<Comprador__c> {
            new Comprador__c(
                Conta__c = accounts.get(0).Id,
                Oportunidade__c = opp.Id
            ),
            new Comprador__c(
                Conta__c = accounts.get(1).Id,
                Oportunidade__c = opp.Id
            ),
            new Comprador__c(
                Conta__c = accounts.get(2).Id,
                Oportunidade__c = opp.Id
            )
        };
    }

    @isTest
    private static void obterInfoContaPorAnaliseCreditoTest() {
        AnaliseDeCredito__c analiseCredito = [SELECT Id, Oportunidade__c FROM AnaliseDeCredito__c LIMIT 1];

        Test.startTest();
        Map<String,Account> accountInfo = AccountService.obterInfoContaPorAnaliseCredito(analiseCredito.Id);
        Test.stopTest();

        Map<String,Account> expectedAccountInfo = new Map<String,Account>();

        List<Comprador__c> compradores = CompradorSelector.obterCompradoresPorOportunidade(analiseCredito.Oportunidade__c);

        for(Comprador__c comprador : compradores) {
            expectedAccountInfo.put(comprador.Conta__r.Name, AccountSelector.obterInfoContaPorId(comprador.Conta__r.Id));
        }

        for (String name : accountInfo.keySet()) {
            Assert.areEqual(accountInfo.get(name), expectedAccountInfo.get(name));
        }
    }
}