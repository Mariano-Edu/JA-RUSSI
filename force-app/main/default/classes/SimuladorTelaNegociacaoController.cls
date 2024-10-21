public class SimuladorTelaNegociacaoController {
   
    @AuraEnabled
    public static List<TabelaVendas__c> obterTabelasPorIdEmpreendimento(Id idEmpreendimento){
        return TabelaVendaSelector.obterTabelasPorIdEmpreendimento(idEmpreendimento);
    }

    @AuraEnabled
    public static List<SeriePagamentos__c> obterSeriesPorIdTabela (Id idTabela){
        return SeriePagamentoSelector.obterSeriePorIdTabelaVendas(idTabela);
    }

    @AuraEnabled
    public static UnidadeTabelaVendas__c obterUnidadeTabelasPorIdUnidade(Id idUnidade){
        return UnidadeTabelaSelector.obterUnidadesTabelaPorIdUnidade(idUnidade);
    }
}