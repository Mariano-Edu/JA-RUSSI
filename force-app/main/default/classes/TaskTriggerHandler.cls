public with sharing class TaskTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        LeadSLAHelper.validateTaskDate(Trigger.new);
        TaskHelper.handleBeforeInsert(Trigger.new);
    }

    public override void afterUpdate() {
        LeadSLAHelper.validateTaskDate(Trigger.new);
        TaskHelper.handleAfterUpdate(Trigger.new);
    }
    
    public override void afterInsert() {
        TaskHelper.handleAfterInsert(Trigger.new);
    }

    public override void afterDelete() {
       TaskHelper.handleAfterDelete(Trigger.old);
    }
}