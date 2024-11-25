trigger TabelaComissaoTrigger on TabelaComissao__c (before insert) {
    new TabelaComissaoTriggerHandler().run();
}