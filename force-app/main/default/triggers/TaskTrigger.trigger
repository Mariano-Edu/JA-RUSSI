trigger TaskTrigger on Task (before insert, before delete, after delete, after insert, before update, after update) {
    new TaskTriggerHandler().run();
}