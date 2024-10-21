trigger AccountTrigger on Account (after insert, before Insert, after update, before update, before delete, after delete) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.run();
}