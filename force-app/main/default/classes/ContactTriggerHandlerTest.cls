@isTest
private class ContactTriggerHandlerTest {
    @isTest static void testBeforeInsert() {

        // Obter o RecordType para Account "Pessoa Jurídica (PJ)"
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaJuridicaPJ' AND SObjectType = 'Account' LIMIT 1];
        
        // Verifica se o tipo de registro foi encontrado
        System.assertNotEquals(null, accountRecordType, 'O tipo de registro "Pessoa Jurídica (PJ)" não foi encontrado.');
        
        // Criando a Account com o campo Name
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Test Account', // Corrigido para usar apenas o campo Name
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                DDICelular__c = null,
                DDITelefone__c = null,
                RecordTypeId = accountRecordType.Id // Usando o RecordTypeId de Pessoa Jurídica (PJ)
            )
        };

        insert accounts;

        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'Test Contact',
                LastName = 'Test',
                Cep__c = '60710-180',
                DataDeNascimento__c = Date.valueOf('2000-07-23'),
                CPF__c = '75230388080',
                DocumentodeIdentificao__c = 'RG',
                OrgaoEmissor__c = 'SSP',
                Email = 'email@example.com',
                WhatsApp__c = '12123456789',
                NumerodoCreci__c = 1232486728,
                DDICelular__c = null,
                DDITelefone__c = null,
                AccountId = accounts[0].Id // Associando a conta ao contato
            )
        };

        Test.startTest();
        insert contacts;
        Test.stopTest();
    }

    @isTest static void testBeforeUpdate() {

        // Obter o RecordType para Account "Pessoa Jurídica (PJ)"
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaJuridicaPJ' AND SObjectType = 'Account' LIMIT 1];
        
        // Verifica se o tipo de registro foi encontrado
        System.assertNotEquals(null, accountRecordType, 'O tipo de registro "Pessoa Jurídica (PJ)" não foi encontrado.');
        
        // Criando a Account com o campo Name
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Test Account', // Corrigido para usar apenas o campo Name
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                DDICelular__c = null,
                DDITelefone__c = null,
                RecordTypeId = accountRecordType.Id // Usando o RecordTypeId de Pessoa Jurídica (PJ)
            )
        };

        insert accounts;

        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'Test Contact',
                LastName = 'Test',
                Cep__c = '60710-180',
                DataDeNascimento__c = Date.valueOf('2000-07-23'),
                CPF__c = '75230388080',
                DocumentodeIdentificao__c = 'RG',
                OrgaoEmissor__c = 'SSP',
                Email = 'email@example.com',
                WhatsApp__c = '12123456789',
                NumerodoCreci__c = 1232486728,
                DDICelular__c = null,
                DDITelefone__c = null,
                AccountId = accounts[0].Id // Associando a conta ao contato
            )
        };

        insert contacts;

        for (Contact c : contacts) {
            c.Email = 'email@example2.com';
        }

        Test.startTest();
        update contacts;
        Test.stopTest();
    }
}