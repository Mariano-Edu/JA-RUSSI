public class TabelaVendaHandler extends TriggerHandler {
    public override void afterInsert() {
        TabelaVendasHelper.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTipoVenda((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTabelaIguais((List<TabelaVendas__c>) Trigger.new);
    }

    public override void afterUpdate() {
        TabelaVendasHelper.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTipoVenda((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTabelaIguais((List<TabelaVendas__c>) Trigger.new);
    }

}