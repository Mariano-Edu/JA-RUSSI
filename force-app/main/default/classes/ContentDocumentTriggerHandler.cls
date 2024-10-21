public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {

    public override void beforeDelete() {
        DocumentoHelper.updateStatusDeleted(Trigger.old);
    }
}