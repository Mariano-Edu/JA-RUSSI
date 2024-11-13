@isTest
public class SimuladorVendasControllerTest {
    
    @TestSetup
    static void makeData(){
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        empreendimento.CNPJ__c = '22026137000158';
        insert empreendimento;

        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;

        PricebookEntry entradaPreco = TestDataFactory.gerarPricebookEntry(produto.Id);
        insert entradaPreco;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.Id;
        insert tabela;
    }

    @isTest
    public static void testBuscarProdutoPorId(){

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        Product2 produtoBuscado = SimuladorVendasController.buscarProdutoPorId(produto.id);
        Test.stopTest();

        Assert.areEqual(produto.Id, produtoBuscado.Id, 'Os Ids devem ser os mesmos');
    }

    @isTest
    public static void testBuscarEntradaTabelaPrecoPorIdDeProduto(){

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
       
        Test.startTest();
        PricebookEntry entrada = SimuladorVendasController.buscarEntradaTabelaPrecoPorIdDeProduto(produto.Id);
        Test.stopTest();

        Assert.areEqual(100, entrada.UnitPrice, 'Os valores devem ser iguais');
    }

    @isTest
    public static void testObterTabelasPorIdEmpreendimento(){
        Empreendimento__c  empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<TabelaVendas__c> tabelas = SimuladorVendasController.obterTabelasPorIdEmpreendimento(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(1, tabelas.size(), 'A lista de tabelas deve ter 1 item');
    }

}