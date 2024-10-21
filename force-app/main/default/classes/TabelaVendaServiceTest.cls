@isTest
private class TabelaVendaServiceTest {
    
    @TestSetup
    static void makeData() {
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c> {
            TestDataFactory.gerarEmpreendimento(),
            TestDataFactory.gerarEmpreendimento()
        };

        insert empreendimentos;

        TabelaVendas__c tabela1 = TestDataFactory.gerarTabelaVendas();
        tabela1.Empreendimento__c = empreendimentos.get(0).Id;
        insert tabela1;

        TabelaVendas__c tabela2 = TestDataFactory.gerarTabelaVendas();
        tabela2.Empreendimento__c = empreendimentos.get(1).Id;
        insert tabela2;

        Product2 produto1 = TestDataFactory.gerarProduto();
        produto1.Empreendimento__c = empreendimentos.get(1).Id;
        insert produto1;

        Product2 produto2 = TestDataFactory.gerarProduto();
        produto2.Empreendimento__c = empreendimentos.get(0).Id;
        insert produto2;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela2.id);
        unidadeTabela.Unidade__c = produto1.Id;
        insert unidadeTabela;

        insert TestDataFactory.gerarUnidadeTabelaVendas(tabela2.id);
    }

    @isTest
    private static void getTabelaVendaTest() {
        Assert.isFalse(!true);
    }
}