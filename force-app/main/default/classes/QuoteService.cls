public with sharing class QuoteService {
    private static final Id SERIE_RECORD_TYPE_ID = Schema.SObjectType.SeriePagamentos__c.getRecordTypeInfosByDeveloperName()
    .get('SerieCotacao')
    .getRecordTypeId();

    public static void handleConcluirSimulacao(List<SeriePagamentos__c> series, List<QuoteLineItem> qlis, Id idCotacao, Boolean isParaAprovacao, Double valorUnidadeTabela) {

        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : qlis) {
            productIds.add(qli.Product2Id);
        }

        Map<Id, Id> pbEntryProductMap = new Map<Id, Id>();
        for (PricebookEntry pbEntry : [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds]) {
            pbEntryProductMap.put(pbEntry.Product2Id, pbEntry.Id);
        }

        for (QuoteLineItem qli : qlis) {
            qli.PricebookEntryId = pbEntryProductMap.get(qli.Product2Id);
        }
        
        for (SeriePagamentos__c serie : series) {
            serie.RecordTypeId = SERIE_RECORD_TYPE_ID;
        }

        insert qlis;
        insert series;

        Quote quoteToUpdate = new Quote(
            Id = idCotacao, 
            Status = 'Em Aprovação', 
            PrecoLista__c = valorUnidadeTabela,
            ComissaoConformeTabela__c = true, 
            DescontoConformeTabela__c = !isParaAprovacao
        );
        
        update quoteToUpdate;
    }

    public static List<QuoteLineItem> criarQuoteLineItems(List<QuoteLineItem> qlis) {
        insert qlis;
        return qlis;
    }

    public static List<SeriePagamentos__c> buscarSeriesPorCotacao(Id idCotacao) {
        return [SELECT 
            Id,
            TipoCondicao__c,
            InicioPagamento__c,
            QuantidadeParcelas__c,
            ValorTotal__c,
            ValorTotalNominal__c,
            DiaVencimentoParcela__c
        FROM SeriePagamentos__c WHERE Cotacao__c = :idCotacao];
    }
}