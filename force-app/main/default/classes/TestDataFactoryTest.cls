@isTest
private class TestDataFactoryTest {

    @TestSetup
    static void makeData() {
        Product2 produto = new Product2();
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        produto.NumeroDaUnidade__c = 777;
        insert produto;

        TabelaVendas__c tabelaVendas = new TabelaVendas__c();
        tabelaVendas.Name = 'Teste'; 
        tabelaVendas.PeriodicidadeParcelaPos__c = 1;
        tabelaVendas.PeriodicidadeParcela__c = '1';
        insert tabelaVendas;
    }
    
    @isTest
    private static void gerarContaTest(){
        Account expectedAccount = new Account();
        expectedAccount.Name = 'Conta de Teste';

        Test.startTest();
        Account actualAccount = TestDataFactory.gerarConta();
        Test.stopTest();

        Assert.areEqual(expectedAccount, actualAccount);
    }

    @isTest
    private static void gerarProdutoTest(){
        Product2 produto = new Product2();
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        produto.NumeroDaUnidade__c = 777;

        Test.startTest();
        Product2 actualProduct = TestDataFactory.gerarProduto();
        Test.stopTest();

        Assert.areEqual(produto, actualProduct);
    }

    @isTest
    private static void gerarPricebookEntryTest() {
        Id idProduto = [SELECT Id FROM Product2 LIMIT 1].Id;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = idProduto;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;

        Test.startTest();
        PricebookEntry actual = TestDataFactory.gerarPricebookEntry(idProduto);
        Test.stopTest();

        Assert.areEqual(pricebookEntry, actual);
    }

    @isTest
    private static void gerarEmpreendimentoTest() {
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJ__c = '22151181000190';


        Test.startTest();
        Empreendimento__c actual = TestDataFactory.gerarEmpreendimento();
        Test.stopTest();

        Assert.areEqual(empreendimento, actual);
    }


    @isTest
    private static void gerarTabelaVendasTest() {
        TabelaVendas__c tabelaVendas = new TabelaVendas__c();
        tabelaVendas.Name = 'Teste'; 
        tabelaVendas.PeriodicidadeParcelaPos__c = 1;
        tabelaVendas.PeriodicidadeParcela__c = '1';

        Test.startTest();
        TabelaVendas__c actual = TestDataFactory.gerarTabelaVendas();
        Test.stopTest(); 

        Assert.areEqual(tabelaVendas, actual);
    }

    @isTest
    private static void gerarSeriePagamentoTest() {
        Id idTabela = [SELECT Id FROM TabelaVendas__c LIMIT 1].Id;

        SeriePagamentos__c serie = new SeriePagamentos__c();
        serie.Name = 'Teste';
        serie.InicioPagamento__c = 1;
        serie.QuantidadeParcelas__c = 1;
        serie.ValorTotal__c= 1;
        serie.TabelaVenda__c = idTabela;
        serie.TipoCondicao__c = 'Ato';


        Test.startTest();
        SeriePagamentos__c actual = TestDataFactory.gerarSeriePagamento(idTabela);
        Test.stopTest();

        Assert.areEqual(serie, actual);
    }

    @isTest
    private static void gerarUnidadeTabelaVendasTest() {
        Id idTabela = [SELECT Id FROM TabelaVendas__c LIMIT 1].Id;

        UnidadeTabelaVendas__c unidadeVenda = new UnidadeTabelaVendas__c();
        unidadeVenda.Name = 'UnidadeVendaTeste';
        unidadeVenda.TabelaVenda__c = idTabela;
        unidadeVenda.PrecoLista__c = 300000;

        Test.startTest();
        UnidadeTabelaVendas__c actual = TestDataFactory.gerarUnidadeTabelaVendas(idTabela);
        Test.stopTest();

        Assert.areEqual(unidadeVenda, actual);
    }
}