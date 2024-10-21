public with sharing class LeadTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        LeadHelper.handleUpdate(Trigger.new, (Map<Id,Lead>) Trigger.oldMap);
    }
   
    public override void beforeInsert() {
        LeadHelper.handleNewLeads(Trigger.new);
    }

    public override void afterInsert() {
        LeadReiterationHelper.handleReiteration(Trigger.new);
    }
}