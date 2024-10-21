trigger DocumentoTrigger on Documento__c (before insert, after insert, before update, after update, before delete) {
    (new DocumentoTriggerHandler()).run();
}