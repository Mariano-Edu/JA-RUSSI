trigger ConfiguracoesDeNegocioTrigger on ConfiguracoesDeNegocio__c (before insert, before update) {
    new ConfiguracoesDeNegocioTriggerHandler().run();
}