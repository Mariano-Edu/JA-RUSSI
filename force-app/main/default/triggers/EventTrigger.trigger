trigger EventTrigger on Event (before insert, after delete, after insert, after update) {
    new EventTriggerHandler().run();
}