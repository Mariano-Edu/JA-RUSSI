public class ContentDocumentLinkController {
    @AuraEnabled
    public static Map<Id, ContentDocumentLink> obterLinksPorDocumentos(List<Documento__c> documentos){
        Map<Id, ContentDocumentLink> mapIdDocumentoContentDocumentLink = new Map<Id, ContentDocumentLink>();

        Set<Id> idsDocumentos = new Set<Id>();

        for(Documento__c documento : documentos) {
            idsDocumentos.add(documento.Id);
        }

        List<ContentDocumentLink> linksDocumentos = ContentDocumentLinkSelector.buscarLinksDocumentosPorSetLinkedEntityId(idsDocumentos);

        for(ContentDocumentLink link : linksDocumentos) {
            mapIdDocumentoContentDocumentLink.put(link.LinkedEntityId, link);
        }

        return mapIdDocumentoContentDocumentLink;
    }
}