trigger SeriePagamentosTrigger on SeriePagamentos__c (before insert, before update) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        SeriePagamentosTriggerHandler.alterarValorRestante(Trigger.new);
    }
}