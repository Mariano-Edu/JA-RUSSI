public with sharing class AccountTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for (Account acc : (List<Account>) Trigger.new) {
            String cep = acc.Cep__c;
            if (!System.isFuture() && !System.isBatch()) {
                AccountHelper.getCEPDataAsyncFuture(cep);                
            } 
        }
    }

    public override void beforeUpdate() {
        for (Account acc: (List<Account>) Trigger.new) {
            String cep = acc.Cep__c;
            if (!System.isFuture() && !System.isBatch()) {
                AccountHelper.getCEPDataAsyncFuture(cep);                
            } 
        }
    }
}