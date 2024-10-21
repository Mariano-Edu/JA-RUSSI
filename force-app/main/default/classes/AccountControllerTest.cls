@isTest
public class AccountControllerTest {
    
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
    }

    @isTest
    private static void obterInfoContaPorAnaliseCreditoTest() {
        Test.startTest();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade 1',
            StageName = 'Proposta',
            CloseDate = System.today().addMonths(1),
            AccountId = accounts.get(3).Id,
            ResponsavelPeloLead__c = [SELECT Id FROM User WHERE Alias = 'user1' LIMIT 1].Id
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

        AnaliseDeCredito__c analiseCredito = [SELECT Id, Oportunidade__c FROM AnaliseDeCredito__c LIMIT 1];

        Map<String,Account> accountInfo = AccountController.obterInfoContaPorAnaliseCredito(analiseCredito.Id);

        Map<String,Account> expectedAccountInfo = new Map<String,Account>();

        List<Comprador__c> compradores = CompradorSelector.obterCompradoresPorOportunidade(analiseCredito.Oportunidade__c);

        for(Comprador__c comprador : compradores) {
            expectedAccountInfo.put(comprador.Conta__r.Name, AccountSelector.obterInfoContaPorId(comprador.Conta__r.Id));
        }

        for (String name : accountInfo.keySet()) {
            Assert.areEqual(accountInfo.get(name), expectedAccountInfo.get(name));
        }
    }

    @isTest
    private static void atualizarValoresContaTest() {
        Test.startTest();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade 1',
            StageName = 'Proposta',
            CloseDate = System.today().addMonths(1),
            AccountId = accounts.get(3).Id,
            ResponsavelPeloLead__c = [SELECT Id FROM User WHERE Alias = 'user1' LIMIT 1].Id
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

        Set<String> fields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet();

        Account account = Database.query(String.format(
            'SELECT {0} FROM Account LIMIT 1',
            new String[]{String.join(new List<String>(fields), ',')}
        ));

        Map<String,String> camposValores = new Map<String,String> {
            'Name' => 'Teste alterado',
            'NumeroDoDocumento__c' => '123',
            'DataDeNascimento__c' => Date.today().addDays(1).toString()
        };

        Id idAccount = account.Id;

        AccountController.atualizarValoresConta(camposValores, idAccount);

        Account updatedAccount = Database.query(String.format(
            'SELECT {0} FROM Account WHERE Id = :idAccount LIMIT 1',
            new String[]{String.join(new List<String>(fields), ',')}
        ));

        for(String campo : camposValores.keySet()) {
            Assert.areNotEqual(account.get(campo), updatedAccount.get(campo));
        }
    }

    @Future
    private static void assignUserRole(Id userId, Id userRoleId) {
        User user = [SELECT Id FROM User WHERE Id = :userId LIMIT 1];
        UserRole userRole = [SELECT Id FROM UserRole WHERE Id = :userRoleId];
        
        user.UserRoleId = userRole.Id;
        update user;
    }
}