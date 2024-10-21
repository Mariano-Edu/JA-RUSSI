public class DocumentoTriggerHandler extends TriggerHandler{
    public override void beforeUpdate() {
        IconeStatusDocumentoService.atualizarIconeStatusDocumento((List<Documento__c>) Trigger.new, (Map<Id, Documento__c>) Trigger.oldMap);
        DocumentoHelper.updateDocStatus((List<Documento__c>) Trigger.new, (Map<Id, Documento__c>) Trigger.oldMap);
    }

    
}