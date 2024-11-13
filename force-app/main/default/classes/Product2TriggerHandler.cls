public with sharing class Product2TriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        Product2Helper.handleAfterInsert(Trigger.new);
    }
}