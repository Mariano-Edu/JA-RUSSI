public without sharing class MessagingSessionTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        MessagingSessionHelper.handleSessionLeads(Trigger.new);
    }
    
    public override void afterUpdate() {
        MessagingSessionHelper.handleSessionLeads(Trigger.new);
    }
}