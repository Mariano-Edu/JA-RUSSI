trigger TabelaDeComissaoTrigger on TabelaDeComissao__c (before update) {
    new TabelaDeComissaoTriggerHandler().run();
}