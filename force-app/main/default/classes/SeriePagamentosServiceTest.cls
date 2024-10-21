@isTest
public with sharing class SeriePagamentosServiceTest {
    
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        seriesTabela.Restante__c = true;
        insert seriesTabela;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        insert unidadeTabela;     
    }

    @isTest
    public static void testSetValorRealVPLTabelaVendas(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];
        Test.startTest();
        Map<String, Decimal> retornoValoresReaisVPL = SeriePagamentosService.setValorRealVPLTabelaVendas(tabela.Id);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisVPL.get('valorVPL'), 'Os valores devem ser iguais.');
    }

    @isTest
    public static void testSetValorRealPropostaCliente(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];

        SeriePagamentosService.ObjetoSerie objetoSerie = new SeriePagamentosService.ObjetoSerie();
        objetoSerie.id = 'serie01';
        objetoSerie.valorTotal = 1;
        objetoSerie.quantidadeParcelas = 1;
        objetoSerie.inicioPagamento = 1;
        objetoSerie.tabelaVenda = tabela.Id;
        objetoSerie.aposHabiteSe = false;

        Test.startTest();
        Map<String, Decimal> retornoValoresReaisProposta = SeriePagamentosService.setValorRealPropostaCliente(tabela.Id,new List<SeriePagamentosService.ObjetoSerie>{objetoSerie}, 300000);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisProposta.get('valorVPL'), 'Os valores devem ser iguais.');
  
    }

    @isTest
    public static void testInsertSeriePagamentos(){
        Test.startTest();
        
        SeriePagamentos__c serie = new SeriePagamentos__c(
            Name = 'Teste',
            InicioPagamento__c = 1,
            QuantidadeParcelas__c = 1,
            ValorTotal__c = 1,
            TabelaVenda__c = [SELECT Id FROM TabelaVendas__c LIMIT 1].Id,
            TipoCondicao__c = 'Ato',
            Restante__c = true
        );
        
        Database.SaveResult resultInsert = Database.insert(serie, false);
        System.assert(resultInsert.isSuccess());
        
        Test.stopTest();
    }
}