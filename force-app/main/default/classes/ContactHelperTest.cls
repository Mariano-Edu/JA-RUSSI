@isTest
private class ContactHelperTest {
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
                DDICelular__c = null,
                DDITelefone__c = null
            )
        };

        insert accounts;


        List <Contact> contacts = new List <Contact>{
            new Contact (
                FirstName = 'Test Contact',
                LastName = 'Test',	
                Bairro__c = 'Teste',
                Numero__c = 123,
                Logradouro__c = 'Logradouro',
                UF__c = 'RJ',
                CidadeEndereco__c = 'Cidade Maravilhosa',
                Cep__c = '01001-000',
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
    private static void getCEPDataAsyncTest() {
        Test.startTest();
            ContactHelper.getCEPDataAsync('01001000');
        Test.stopTest();
    }

    @isTest
    private static void updateContactWithCEPTest() {
        ViaCEPResponse viaCEPResponse = new ViaCEPResponse( '01001-000', 'Praça da Sé', 'lado ímpar', 'Sé', 'São Paulo', 'SP', '3550308', '1004', '11', '7107');

        Contact contatoAntiga = [SELECT Id, Bairro__c, CidadeEndereco__c, UF__c, Logradouro__c FROM Contact LIMIT 1];

        Test.startTest();
            ContactHelper.updateContactWithCEP('01001-000', viaCEPResponse);
        Test.stopTest();

        Contact contatoAtualizada = [SELECT Id, Bairro__c, CidadeEndereco__c, UF__c, Logradouro__c FROM Contact LIMIT 1];

        Assert.areNotEqual(contatoAntiga.Bairro__c, contatoAtualizada.Bairro__c);
        Assert.areNotEqual(contatoAntiga.CidadeEndereco__c, contatoAtualizada.CidadeEndereco__c);
        Assert.areNotEqual(contatoAntiga.UF__c, contatoAtualizada.UF__c);
        Assert.areNotEqual(contatoAntiga.Logradouro__c, contatoAtualizada.Logradouro__c);
    }
}