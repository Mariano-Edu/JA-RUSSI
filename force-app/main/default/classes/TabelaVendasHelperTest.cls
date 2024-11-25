@isTest
private class TabelaVendasHelperTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
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
    private static void inserirUnidadesTabelasInsertTest() {
        Set<Id> idsTabelasComUnidade = ObjectHelper.getLookUpId(
            [SELECT TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c != null],
            'TabelaVenda__c'
        );

        List<TabelaVendas__c> tabelas = [
            SELECT
                Id,
                Empreendimento__c
            FROM TabelaVendas__c WHERE Id NOT IN :idsTabelasComUnidade
        ];

        Test.startTest();
        TabelaVendasHelper.inserirUnidadesTabelas(tabelas);
        Test.stopTest();

        List<UnidadeTabelaVendas__c> unidadesTabelas = [
            SELECT 
                Id
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :(new Map<Id,TabelaVendas__c>(tabelas).keySet())
        ];

        Assert.isFalse(unidadesTabelas.isEmpty());
    }

    @isTest
    private static void inserirUnidadesTabelasUpdateTest() {
        Set<Id> idsTabelasComUnidade = ObjectHelper.getLookUpId(
            [SELECT TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c != null],
            'TabelaVenda__c'
        );

        List<TabelaVendas__c> tabelas = [
            SELECT
                Id,
                Empreendimento__c
            FROM TabelaVendas__c WHERE Id IN :idsTabelasComUnidade
        ];

        UnidadeTabelaVendas__c unidadesTabela = [
            SELECT 
                Id,
                Name,
                PrecoLista__c,
                CoeficienteTabela__c,
                MetragemUnidade__c,
                Unidade__c,
                TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :idsTabelasComUnidade
            LIMIT 1
        ];

        Test.startTest();
        TabelaVendasHelper.inserirUnidadesTabelas(tabelas);
        Test.stopTest();

        UnidadeTabelaVendas__c unidadesTabelaUpdated = [
            SELECT 
                Id,
                Name,
                PrecoLista__c,
                CoeficienteTabela__c,
                MetragemUnidade__c,
                Unidade__c,
                TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :idsTabelasComUnidade
            LIMIT 1
        ];

        Assert.areNotEqual(unidadesTabela, unidadesTabelaUpdated);
    }


    
}