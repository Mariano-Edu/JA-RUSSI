public with sharing class TabelaDeComissaoTriggerHandler extends TriggerHandler{
    public override void beforeUpdate(){
        TabelaDeComissaoDomain.handleBeforeUpdate(
            (List<TabelaDeComissao__c>) Trigger.new, (Map<Id, TabelaDeComissao__c>) Trigger.oldMap
        );
    }
    
    public override void beforeInsert(){
    }

    public override void afterInsert() {
    }

    public override void afterDelete() {
    }
}