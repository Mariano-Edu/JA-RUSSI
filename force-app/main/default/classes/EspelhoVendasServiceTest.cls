@isTest
public class EspelhoVendasServiceTest {
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Tower test',
            CNPJ__c = '38514518000116',
            DisponivelNoEspelho__c = true
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
            NumeroDaUnidade__c = 1,
            Status__c = 'Disponível',
            Empreendimento__c = empreendimento.Id
        );

        insert unidade;
    }


    @isTest
    static void testGetEmpreendimentosDisponiveis() {
        Test.startTest();
        List<Empreendimento__c> result = EspelhoVendasService.getEmpreendimentosDisponiveis();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testRetornarUnidadesDisponiveis() {
        Id idEmpreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        Test.startTest();
        List<Product2> result = EspelhoVendasService.retornarUnidadesDisponiveis(idEmpreendimento);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de unidades disponíveis');
    }

    @isTest
    static void buscarBlocosPorEmpreendimentoTest() {
        Id idEmpreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        Test.startTest();
        List<Bloco__c> result = EspelhoVendasService.buscarBlocosPorEmpreendimento(idEmpreendimento);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de unidades disponíveis');
    }

    @isTest
    static void testBuscarNomesEmpreendimentos() {
        Test.startTest();
        List<String> result = EspelhoVendasService.buscarNomesEmpreendimentos();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de nomes de empreendimentos');
    }

    // @isTest
    // static void testGetConfiguracaoEspelho() {
    //     Test.startTest();
    //     // Simula a recuperação de dados de metadados personalizados
    //     List<Configura_o_de__mdt> configuracoes = new List<Configura_o_de__mdt>();

    //     for (Integer i = 0; i < 3; i++) {
    //         Configura_o_de__mdt config = new Configura_o_de__mdt();
    //         config.Status__c = 'Status ' + i;
    //         config.Cor__c = 'Cor ' + i;
    //         configuracoes.add(config);
    //     }

    //     Test.setMock(Configura_o_de__mdt.class, configuracoes);
        
    //     List<Configura_o_de__mdt> result = EspelhoVendasService.getConfiguracaoEspelho();
    //     Test.stopTest();

    //     System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de configurações de espelho');
    // }

    @isTest
    static void testBuscarStatusUnidades() {
        Test.startTest();
        List<String> result = EspelhoVendasService.buscarStatusUnidades();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de status de unidades');
    }

    @isTest
    static void testBuscarTiposUnidades() {
        Test.startTest();
        List<RecordType> result = EspelhoVendasService.buscarTiposUnidades();
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de tipos de unidades');
    }
}