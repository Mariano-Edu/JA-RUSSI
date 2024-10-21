public class TabelaVendaHandler extends TriggerHandler {
    public override void afterInsert() {
        TabelaVendasHelper.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.clonarSeriePagamento((List<TabelaVendas__c>) Trigger.new);
    }

    public override void afterUpdate() {
        TabelaVendasHelper.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);

    }

    public override void beforeInsert(){
        TabelaVendasHelper.validarTipoVenda((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTabelaIguais((List<TabelaVendas__c>) Trigger.new);
    }

    public override void beforeUpdate(){
        TabelaVendasHelper.validarTipoVenda((List<TabelaVendas__c>) Trigger.new);
        TabelaVendasHelper.validarTabelaIguais((List<TabelaVendas__c>) Trigger.new);
    }
}