trigger CompradorTrigger on Comprador__c (before insert, after insert, before update, after update, before delete) {
   (new CompradorTriggerHandler()).run();
}