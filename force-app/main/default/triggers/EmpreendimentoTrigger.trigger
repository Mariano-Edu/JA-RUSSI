trigger EmpreendimentoTrigger on Empreendimento__c (after insert, before insert, after update, before update, before delete, after delete) {
    EmpreendimentoTriggerHandler handler = new EmpreendimentoTriggerHandler ();
    handler.run();
}