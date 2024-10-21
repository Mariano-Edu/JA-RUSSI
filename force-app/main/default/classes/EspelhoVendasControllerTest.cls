@isTest
public class EspelhoVendasControllerTest {
/*
    @TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c>{
            new Empreendimento__c(
                Name = 'Test Empreendimento',
                CNPJ__c = '71273553000166'
            )
        };

        insert empreendimentos;

        Product2 unidade1 = new Product2(
            Name = 'Unidade 1',
            NumeroDaUnidade__c = 1,
            Empreendimento__c = empreendimentos[0].Id,
            Status__c = 'Disponível'
        );

        Product2 unidade2 = new Product2(
            Name = 'Unidade 2',
            NumeroDaUnidade__c = 2,
            Empreendimento__c = empreendimentos[0].Id,
            Status__c = 'Reservada'
        );

        insert new List<Product2>{unidade1, unidade2};
    }

    @isTest
    static void testGetEmpreendimentosDisponiveis() {
        Test.startTest();
        List<Empreendimento__c> result = EspelhoVendasController.getEmpreendimentosDisponiveis();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testBuscarNomesEmpreendimentos() {
        Test.startTest();
        List<String> result = EspelhoVendasController.buscarNomesEmpreendimentos();
        Test.stopTest();

        List<Product2> products = [SELECT Empreendimento__r.Name FROM Product2 WHERE Empreendimento__r.Name != NULL];

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de nomes de empreendimentos');
    }

    @isTest
    static void testRetornarUnidadesDisponiveis() {
        Id idEmpreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        Test.startTest();
        List<Product2> result = EspelhoVendasController.retornarUnidadesDisponiveis(idEmpreendimento);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de unidades disponíveis');
    }

    @isTest
    static void testBuscarStatusUnidades() {
        Test.startTest();
        List<String> result = EspelhoVendasController.buscarStatusUnidades();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de status de unidades');
    }

    @isTest
    static void testBuscarTiposUnidades() {
        Test.startTest();
        List<RecordType> result = EspelhoVendasController.buscarTiposUnidades();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de tipos de unidades');
    }

    @isTest
    static void testGetConfiguracaoEspelho() {
        Test.startTest();
        List<Configura_o_de__mdt> result = EspelhoVendasController.getConfiguracaoEspelho();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de configurações de espelho');
    }*/
}