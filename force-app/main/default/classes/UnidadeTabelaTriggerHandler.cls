public with sharing class UnidadeTabelaTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        UnidadeTabelaService.updateOpportunitiesFromQuotes((List<UnidadeTabelaVendas__c>) Trigger.new, (Map<Id, UnidadeTabelaVendas__c>) Trigger.oldMap);
    }
}