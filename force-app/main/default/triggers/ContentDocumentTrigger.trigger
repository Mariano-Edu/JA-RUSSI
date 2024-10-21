trigger ContentDocumentTrigger on ContentDocument (before delete) {
    new ContentDocumentTriggerHandler().run();
}