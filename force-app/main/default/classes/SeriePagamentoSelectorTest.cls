@isTest
private class SeriePagamentoSelectorTest {

    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        insert unidadeTabela;
    }
    

    @isTest
    private static void obterSeriePorIdTest() {
        Id idSerie = [SELECT Id FROM SeriePagamentos__c LIMIT 1].Id;

        Test.startTest();
        List<SeriePagamentos__c> series = SeriePagamentoSelector.obterSeriePorId(idSerie);
        Test.stopTest();

        Assert.isNotNull(series);
        Assert.isFalse(series.isEmpty());
    }
}