@isTest
private class EmpreendimentoHelperTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        List<Empreendimento__c> emp = new List<Empreendimento__c>{
            new Empreendimento__c(
                Name = 'Test Empreendimento',
                CNPJ__c = '71273553000166',
                CEP__c = '76979970' // CNPJ e CEP no formato correto
            )
        };

        insert emp;
    }

    // Testando o método @future getCEPDataAsyncFuture
    @isTest
    static void testGetCEPDataAsyncFuture() {
        Test.startTest();
            EmpreendimentoHelper.getCEPDataAsyncFuture('01001000');
        Test.stopTest();
    }

    @isTest
    static void updateEmpreendimentoWithCEPTest() {
        Empreendimento__c empreendimentoParaAtualizar = new Empreendimento__c(
            Name = 'Empreendimento para Atualizar',
            CNPJ__c = '71273553000166',
            CEP__c = '68904620'
        );
        insert empreendimentoParaAtualizar;

        ViaCEPResponse viaCEPResponse = new ViaCEPResponse(
            '01001000', 'Praça da Sé', 'lado ímpar', 'Sé', 'São Paulo', 'SP', '3550308', '1004', '11', '7107'
        );

        Test.startTest();
            EmpreendimentoHelper.updateEmpreendimentoWithCEP('68904620', viaCEPResponse);
        Test.stopTest();

        Empreendimento__c empreendimentoAtualizado = [SELECT Id, Bairro__c, Cidade__c, UF__c, Logradouro__c FROM Empreendimento__c WHERE Id = :empreendimentoParaAtualizar.Id LIMIT 1];

        System.assertNotEquals(null, empreendimentoAtualizado.Bairro__c);
        System.assertNotEquals(null, empreendimentoAtualizado.Cidade__c);
        System.assertNotEquals(null, empreendimentoAtualizado.UF__c);
        System.assertNotEquals(null, empreendimentoAtualizado.Logradouro__c);
    }

    @isTest
    public static void getEmpreendimentosResponseTest() {
        List<EmpreendimentoResponse> empreendimentosResponse = EmpreendimentoHelper.getEmpreendimentosResponse();
        System.assertEquals(1, empreendimentosResponse.size(), 'Deve retornar 1 empreendimento');
        System.assertEquals('Test Empreendimento', empreendimentosResponse[0].razaoSocial, 'Nome do empreendimento deve ser "Test Empreendimento"');
    }
}