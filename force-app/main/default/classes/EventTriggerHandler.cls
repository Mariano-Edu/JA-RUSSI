public with sharing class EventTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        EventHelper.validateEventLookup(Trigger.new);
        LeadSLAHelper.validateEventDate(Trigger.new);
    }

    public override void beforeUpdate() {
        
        LeadSLAHelper.validateEventDate(Trigger.new);
    }
    
    public override void afterDelete() {
        ActivityHelper.updateTotalLeadActivities(Trigger.old);
    }
    
    public override void afterInsert() {
        ActivityHelper.updateTotalLeadActivities(Trigger.new);
    }
}