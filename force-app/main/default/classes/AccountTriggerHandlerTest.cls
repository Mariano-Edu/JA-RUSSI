@isTest
private class AccountTriggerHandlerTest {
    @isTest static void testBeforeInsert() {

        // Obter o RecordType para Account (usando o nome do tipo de registro)
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaJuridicaPJ' AND SObjectType = 'Account' LIMIT 1];

        // Verifica se o tipo de registro foi encontrado
        System.assertNotEquals(null, accountRecordType, 'O tipo de registro "Pessoa Jurídica (PJ)" não foi encontrado.');
 
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Test Account', // O objeto Account usa "Name" ao invés de "FirstName" e "LastName"
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Cep__c = '60710-180',
                RecordTypeId = accountRecordType.Id // Associando o RecordTypeId correto
            )
        };

        Test.startTest();
        insert accounts;
        Test.stopTest();
    }

    @isTest static void testBeforeUpdate() {

        // Obter o RecordType para Account (usando o nome do tipo de registro)
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaJuridicaPJ' AND SObjectType = 'Account' LIMIT 1];

        // Verifica se o tipo de registro foi encontrado
        System.assertNotEquals(null, accountRecordType, 'O tipo de registro "Pessoa Jurídica (PJ)" não foi encontrado.');

        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Test Account', // O objeto Account usa "Name" ao invés de "FirstName" e "LastName"
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Cep__c = '60710-180',
                RecordTypeId = accountRecordType.Id // Associando o RecordTypeId correto
            )
        };

        insert accounts;

        // Atualizando o campo EmailPJ__c
        for(Account acc : accounts) {
            acc.EmailPJ__c = 'email@example.com';
        }

        Test.startTest();
        update accounts;
        Test.stopTest();
    }
}