public class SeriePagamentosTriggerHandler {
    public static void alterarValorRestante(List<SeriePagamentos__c> newSeriePagamentos) {
        Map<Id, SeriePagamentos__c> novaSeriesMap = new Map<Id, SeriePagamentos__c>();

        // Mapeia todos os registros que têm o campo Restante ativo
        for (SeriePagamentos__c sp : newSeriePagamentos) {
            if (sp.Restante__c) {
                novaSeriesMap.put(sp.TabelaVenda__c, sp);
            }
        }

        if (!novaSeriesMap.isEmpty()) {
            List<SeriePagamentos__c> existingSeries = SeriePagamentoSelector.obterSeriesPeloRestante(novaSeriesMap.keySet());

            List<SeriePagamentos__c> seriesParaDesativar = new List<SeriePagamentos__c>();

            for (SeriePagamentos__c existingSp : existingSeries) {
                SeriePagamentos__c spToUpdate = novaSeriesMap.get(existingSp.TabelaVenda__c);

                if (spToUpdate != null && spToUpdate.Id != existingSp.Id) {
                    existingSp.Restante__c = false;
                    seriesParaDesativar.add(existingSp);
                }
            }
            if (!seriesParaDesativar.isEmpty()) {
                update seriesParaDesativar;
            }
        }
    }
}