@isTest
public with sharing class SimuladorTelaNegociacaoControllerTest {
    
    @TestSetup
    static void makeData(){
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        empreendimento.CNPJ__c = '22026137000158';
        insert empreendimento;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.id;
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert serie;

        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;

        UnidadeTabelaVendas__c unidade = TestDataFactory.gerarUnidadeTabelaVendas(tabela.Id);
        unidade.Unidade__c = produto.Id;
        insert unidade;
    }

    @isTest
    public static void testObterTabelasPorIdEmpreendimento(){
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        test.startTest();
        List<TabelaVendas__c> tabelas = SimuladorTelaNegociacaoController.obterTabelasPorIdEmpreendimento(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(1, tabelas.size(), 'A lista deve ter 1 item');
    }

    @isTest
    public static void testObterSeriesPorIdTabela(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];

        test.startTest();
        List<SeriePagamentos__c> series = SimuladorTelaNegociacaoController.obterSeriesPorIdTabela(tabela.Id);
        Test.stopTest();

        Assert.areEqual(1, series.size(), 'A lista deve ter 1 item');
    }

    @isTest
    public static void testObterUnidadeTabelasPorIdUnidade(){
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        test.startTest();
        UnidadeTabelaVendas__c unidade = SimuladorTelaNegociacaoController.obterUnidadeTabelasPorIdUnidade(produto.Id);
        Test.stopTest();

        Assert.areEqual(produto.Id, unidade.Unidade__c, 'os ids devem ser iguais');
    }

}