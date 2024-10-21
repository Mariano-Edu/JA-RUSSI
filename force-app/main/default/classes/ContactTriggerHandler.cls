public with sharing class ContactTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for (Contact ctt : (List<Contact>) Trigger.new) {
            String cep = ctt.Cep__c;
            if (!System.isFuture() && !System.isBatch()) {
                ContactHelper.getCEPDataAsyncFuture(cep);                
            } 
        }
    }

    public override void beforeUpdate() {
        for (Contact ctt : (List<Contact>) Trigger.new) {
            String cep = ctt.Cep__c;
            if (!System.isFuture() && !System.isBatch()) {
                ContactHelper.getCEPDataAsyncFuture(cep);                
            } 
        }
    }
}