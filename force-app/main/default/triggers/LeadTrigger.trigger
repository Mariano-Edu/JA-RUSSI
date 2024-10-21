trigger LeadTrigger on Lead (before update, before insert, after insert) {
    new LeadTriggerHandler().run();
}