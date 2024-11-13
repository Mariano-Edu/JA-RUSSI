public class SimuladorTelaNegociacaoController {
   
    @AuraEnabled
    public static List<TabelaVendas__c> obterTabelasPorIdEmpreendimento(Id idEmpreendimento){
        return TabelaVendasSelector.obterTabelasPorIdEmpreendimento(idEmpreendimento);
    }
   
    @AuraEnabled(cacheable = true)
    public static List<TabelaVendas__c> obterTabelasVigentesPorIdEmpreendimentoETipoVenda(Id idEmpreendimento, String tipoVenda){
        return TabelaVendasSelector.obterTabelasVigentesPorIdEmpreendimentoETipoVenda(idEmpreendimento, tipoVenda);
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