@IsTest
public class ExtratoTabelaServiceTest {
    
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.Id);
        serie.AposHabiteSe__c = false;
        insert serie;

        SeriePagamentos__c serie2 = TestDataFactory.gerarSeriePagamento(tabela.Id);
        serie2.AposHabiteSe__c = false;
        serie2.TipoCondicao__c = 'Mensais';
        insert serie2;
    }

    @isTest
    public static void testAnalisarProposta(){

        List<SeriePagamentos__c> series = [SELECT Id, Name,InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        TabelaVendas__c tabela = [SELECT Id,Name FROM TabelaVendas__c LIMIT 1];
        Map<String, Object> valoresMatriz = new Map<String, Object>{
            'nominalProposta' => 100000, 
            'nominalTabela' => 200000, 
            'valorVplProposta' => 80000, 
            'valorVplTabela' => 160000
        };

        Test.startTest();
        List<Object> retorno = ExtratoTabelaService.analisarProposta(tabela.id, series, valoresMatriz);
        Test.stopTest();

        Assert.areEqual(true, (retorno.size() > 0), 'A lista não pode estar vazia');
    }

}