@isTest
private class ContactDATest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){

        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Test Account',
                CNPJ__c = '45246904000130',
                Type = 'Consulta',
                PrimeiraCompra__c = 'SIM',
                EmailPJ__c = 'teste@email.com',
                WhatsApp__c = '113478374879',
                PreferenciaDeContato__c = 'E-mail',
                Bairro__c = 'Teste',
                Numero__c = 123,
                DDICelular__c = null,
                DDITelefone__c = null
            )
        };

        insert accounts;


        List <Contact> contacts = new List <Contact>{
            new Contact (
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
                AccountId = accounts.get(0).Id
            )   
        };
        
        insert contacts;
    }

    @isTest
    static void getContactsByIdTest() {
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Id idContact = contacts.get(0).Id;

        Assert.areEqual(contacts, ContactDA.getContactsById(new Set<String>{'Id'}, new Set<Id>{idContact}));
    }
}