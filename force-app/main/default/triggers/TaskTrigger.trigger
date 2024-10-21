trigger TaskTrigger on Task (before insert, before delete, after delete, after insert, before update) {
    new TaskTriggerHandler().run();
}