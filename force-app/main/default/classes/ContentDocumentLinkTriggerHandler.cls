public class ContentDocumentLinkTriggerHandler extends TriggerHandler{
    public override void beforeInsert() {
        ContentDocumentLinkService.substituirLinkDocumento((List<ContentDocumentLink>) Trigger.new);
        // ContentDocumentLinkService.verificarOportunidadeMontagemPasta((List<ContentDocumentLink>) Trigger.new);
    }

    public override void afterInsert() {
        EntregaDocumento.AtualizarDocumentoEntregue((List<ContentDocumentLink>) Trigger.new);
    }
}