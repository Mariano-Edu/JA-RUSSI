public class TabelaVendaHandler extends TriggerHandler {
    public override void afterInsert() {
        TabelaVendasHelper.inserirUnidadesTabelas(Trigger.new);
        TabelaVendasHelper.validarTipoVenda(Trigger.new);
        TabelaVendasHelper.validarTabelaIguais(Trigger.new, false);
    }

    public override void afterUpdate() {
        TabelaVendasHelper.inserirUnidadesTabelas(Trigger.new);
        TabelaVendasHelper.validarTipoVenda(Trigger.new);
        TabelaVendasHelper.validarTabelaIguais(Trigger.new, false);

    }

    public override void beforeUpdate() {
        TabelaVendasHelper.handleBeforeUpdate((List<TabelaVendas__c>)Trigger.new, (Map<Id, TabelaVendas__c>)Trigger.oldMap);
        TabelaVendasHelper.ativarTabelaVendas(Trigger.new);

    }

    public override void beforeInsert() {
        TabelaVendasHelper.handleBeforeUpdate((List<TabelaVendas__c>)Trigger.new, (Map<Id, TabelaVendas__c>)Trigger.oldMap);
        TabelaVendasHelper.validarTabelaIguais(Trigger.new, false);
        TabelaVendasHelper.validarTipoVenda(Trigger.new);


    }

}