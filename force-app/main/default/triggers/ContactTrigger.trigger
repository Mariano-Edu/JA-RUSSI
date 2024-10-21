trigger ContactTrigger on Contact (after insert, before Insert, after update, before update, before delete, after delete) {
    ContactTriggerHandler handler = new ContactTriggerHandler();
    handler.run();
}