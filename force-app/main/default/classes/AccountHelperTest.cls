@isTest
private class AccountHelperTest {

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
                Cep__c = '01001-000',
                DDICelular__c = null,
                DDITelefone__c = null
            )
        };
        insert accounts;
    }

    @IsTest
    static void testUpdateAccountWithCEP() {
        // Simular resposta válida do ViaCEP
        ViaCEPResponse viaCEPResponse = new ViaCEPResponse('01001-000', 'Praça da Sé', 'lado ímpar', 'Sé', 'São Paulo', 'SP', '3550308', '1004', '11', '7107');
        
        // Chamar o método de atualização da conta
        AccountHelper.updateAccountWithCEP('01001-000', viaCEPResponse);

        // Verificar se os dados da conta foram atualizados corretamente
        Account updatedAccount = [SELECT Bairro__c, Cidade__c, Uf__c, Logradouro__c FROM Account WHERE Cep__c = '01001-000'];
        System.assertEquals('Sé', updatedAccount.Bairro__c);
        System.assertEquals('São Paulo', updatedAccount.Cidade__c);
        System.assertEquals('SP', updatedAccount.Uf__c);
        System.assertEquals('Praça da Sé', updatedAccount.Logradouro__c);
    }

    @IsTest
    static void testGetCEPDataAsync() {
        // Simular a chamada externa com HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Chamar o método assíncrono diretamente
        Test.startTest();
        AccountHelper.getCEPDataAsync('01001-000');
        Test.stopTest();

        // Verificar se os dados da conta foram atualizados corretamente
        Account updatedAccount = [SELECT Bairro__c, Cidade__c, Uf__c, Logradouro__c FROM Account WHERE Cep__c = '01001-000'];
        System.assertEquals('Sé', updatedAccount.Bairro__c);
        System.assertEquals('São Paulo', updatedAccount.Cidade__c);
        System.assertEquals('SP', updatedAccount.Uf__c);
        System.assertEquals('Praça da Sé', updatedAccount.Logradouro__c);
    }

    @IsTest
    static void testGetCEPDataAsyncFuture() {
        // Simular a chamada externa com HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Chamar o método @future
        Test.startTest();
        AccountHelper.getCEPDataAsyncFuture('01001-000');
        Test.stopTest();

        // Verificar se os dados da conta foram atualizados corretamente
        Account updatedAccount = [SELECT Bairro__c, Cidade__c, Uf__c, Logradouro__c FROM Account WHERE Cep__c = '01001-000'];
        System.assertEquals('Sé', updatedAccount.Bairro__c);
        System.assertEquals('São Paulo', updatedAccount.Cidade__c);
        System.assertEquals('SP', updatedAccount.Uf__c);
        System.assertEquals('Praça da Sé', updatedAccount.Logradouro__c);
    }
}