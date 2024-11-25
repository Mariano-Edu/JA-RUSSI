@isTest
private class UnidadeTabelaSelectorTest {
    
    @TestSetup
    static void makeData() {
        TabelaVendas__c tabela = new TabelaVendas__c();
        tabela.Name = 'Teste'; 
        tabela.PeriodicidadeParcelaPos__c = 1;
        tabela.PeriodicidadeParcela__c = '1';
        insert tabela;

        UnidadeTabelaVendas__c unidadeVenda = new UnidadeTabelaVendas__c();
        unidadeVenda.Name = 'UnidadeVendaTeste';
        unidadeVenda.TabelaVenda__c = tabela.Id;
        unidadeVenda.PrecoLista__c = 300000;
        insert unidadeVenda;
    }

    @isTest
    private static void obterUnidadeTabelaPorIdTest() {
        List<UnidadeTabelaVendas__c> unidadesTabela = [
            SELECT
            Id,
            TabelaVenda__c,
            PrecoLista__c
            FROM UnidadeTabelaVendas__c
        ];

        Test.startTest();
        List<UnidadeTabelaVendas__c> actual = UnidadeTabelaSelector.obterUnidadeTabelaPorId(unidadesTabela.get(0).TabelaVenda__c);
        Test.stopTest();

        Assert.areEqual(unidadesTabela, actual);
    }

    @isTest
    private static void obterUnidadesTabelaExistentesTest() {
        Set<Id> tabelaVendasIds = new Map<Id,TabelaVendas__c>([SELECT Id FROM TabelaVendas__c]).keySet();

        Map<Id,UnidadeTabelaVendas__c> unidadesTabelaMap = new Map<Id, UnidadeTabelaVendas__c>([
            SELECT Id, Name, PrecoLista__c, CoeficienteTabela__c, MetragemUnidade__c, Unidade__c, TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :tabelaVendasIds
        ]);

        Test.startTest();
        Map<Id,UnidadeTabelaVendas__c> actual = UnidadeTabelaSelector.obterUnidadesTabelaExistentes(tabelaVendasIds);
        Test.stopTest();

        for(Id idUnidade : unidadesTabelaMap.keySet()) {
            Assert.isTrue(actual.containsKey(idUnidade));
            Assert.areEqual(unidadesTabelaMap.get(idUnidade), actual.get(idUnidade));
        }
    }

    @isTest
    private static void obterUnidadesTabelaPorIdUnidadeTest() {
        UnidadeTabelaVendas__c unidade = [
            SELECT 
                Id,
                ValorVenda__c,
                Unidade__c
            FROM UnidadeTabelaVendas__c
            LIMIT 1
        ];

        Test.startTest();
        UnidadeTabelaVendas__c actual = UnidadeTabelaSelector.obterUnidadesTabelaPorIdUnidade(unidade.Unidade__c);
        Test.stopTest();

        Assert.areEqual(unidade, actual);
    }
}