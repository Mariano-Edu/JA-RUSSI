trigger TabelaVendaTrigger on TabelaVendas__c (after insert, after update , before insert, before update) {
    new TabelaVendaHandler().run();
}