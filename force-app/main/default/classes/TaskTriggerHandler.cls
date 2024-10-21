public with sharing class TaskTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        LeadSLAHelper.validateTaskDate(Trigger.new);
    }

    public override void beforeUpdate() {
        LeadSLAHelper.validateTaskDate(Trigger.new);
    }
    
    public override void afterInsert() {
        TaskHelper.handleAfterInsert(Trigger.new);
    }

    public override void afterDelete() {
       TaskHelper.handleAfterDelete(Trigger.old);
    }
}