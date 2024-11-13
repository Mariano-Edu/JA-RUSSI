public class CotacaoController {
    @AuraEnabled(cacheable = true)
    public static Map<Id, UnidadeTabelaVendas__c> obterEntradaPrecoPorUnidade(Id idTabela){
        try {
            return SeriePagamentosService.obterEntradaPrecoPorTabela(idTabela);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Quote criarCotacaoPorOportunidade(Id opportunityId) {
        
        try {
            Opportunity opp = OpportunitySelector.obterOportunidadePorId(opportunityId);
            
            Quote newQuote = new Quote(
                OpportunityId = opp.Id,
                Name = 'Cotação'
            );  
            
            insert newQuote;
            return newQuote;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<QuoteLineItem> criarQuoteLineItems(List<QuoteLineItem> qlis){
        try {
            return QuoteService.criarQuoteLineItems(qlis);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void concluirSimulacao(List<SeriePagamentos__c> series, List<QuoteLineItem> qlis, Id idCotacao, Boolean isParaAprovacao, Double valorUnidadeTabela){
        try {
            QuoteService.handleConcluirSimulacao(series, qlis, idCotacao, isParaAprovacao, valorUnidadeTabela);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<SeriePagamentos__c> buscarSeriesPorCotacao(Id idCotacao){
        try {
            return QuoteService.buscarSeriesPorCotacao(idCotacao);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Object> analisarProposta(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz){
        List<Object> resultado = ExtratoTabelaService.analisarProposta(tabelaId, proposta, valoresMatriz);
        return resultado;
    }
}