trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    new ContentDocumentLinkTriggerHandler().run();
}