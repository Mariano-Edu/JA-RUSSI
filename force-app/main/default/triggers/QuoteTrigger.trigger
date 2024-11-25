trigger QuoteTrigger on Quote (after update, before update, before insert, after insert) {
    new QuoteTriggerHandler().run();
}