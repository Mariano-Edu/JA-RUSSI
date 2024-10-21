public class EntregaDocumento {
    public static void AtualizarDocumentoEntregue(List<ContentDocumentLink> linksDocumentos) {
        List<Documento__c> documentosAtualizar = new List<Documento__c>();

        for(ContentDocumentLink linkDocumento : linksDocumentos) {
            if(String.valueOf(linkDocumento.LinkedEntityId.getsobjecttype()) == 'Documento__c') {
                Documento__c documento = DocumentoSelector.obterDocumentoPorId(linkDocumento.LinkedEntityId);
                documento.Entregue__c = true;
                documento.StatusAprovacao__c = 'Entregue';
    
                documentosAtualizar.add(documento);
            }
        }

        if(!documentosAtualizar.isEmpty()) {
            update documentosAtualizar;
        }
    }
}