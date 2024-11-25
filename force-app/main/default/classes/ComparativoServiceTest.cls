@isTest
public with sharing class ComparativoServiceTest {
    @TestSetup
    static void makeData(){

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        empreendimento.MetragemPrivativaTotal__c = 100;
        empreendimento.CNPJ__c = '41956129000155';
        insert empreendimento;

        Product2 produto = TestDataFactory.gerarProduto();
        produto.Empreendimento__c = empreendimento.Id;
        insert produto;


        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.id;
        insert tabela;

        UnidadeTabelaVendas__c entradaPreco = TestDataFactory.gerarUnidadeTabelaVendas(tabela.Id);
        entradaPreco.Unidade__c = produto.Id;
        insert entradaPreco;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert serie;
    }

    @isTest
    public static void testCalcularComparacao() {
        TabelaVendas__c tabela = [SELECT Id, Name FROM TabelaVendas__c LIMIT 1];
        UnidadeTabelaVendas__c unidade = [SELECT Id, Name FROM UnidadeTabelaVendas__c WHERE Name = 'UnidadeVendaTeste' LIMIT 1];
        List<SeriePagamentos__c> series = [SELECT Id, Name,InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c, ValorTotalNominal__c FROM SeriePagamentos__c];
    
        Test.startTest();
        List<Object> comparativo = ComparativoService.calcularComparacao(unidade.Id, tabela.Id, series);
        Test.stopTest();

        Assert.areEqual(true, (comparativo.size() > 0), 'A lista não pode estar vazia');
    }
}