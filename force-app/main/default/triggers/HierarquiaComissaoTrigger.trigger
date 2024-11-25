trigger HierarquiaComissaoTrigger on HierarquiaComissao__c (before insert) {
    new HierarquiaComissaoTriggerHandler().run();
}