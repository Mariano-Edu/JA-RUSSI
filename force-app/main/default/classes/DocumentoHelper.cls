public with sharing class DocumentoHelper {
    public static void updateDocStatus(List<Documento__c> newDocs, Map<Id, Documento__c> oldDocs) {
        if (newDocs == null || oldDocs == null) {
            return;
        }
        
        Set<Id> docIds = new Set<Id>();
        for (Documento__c doc : newDocs) {
            docIds.add(doc.Id);
        }
        
        Map<Id, List<ContentDocumentLink>> docLinksMap = new Map<Id, List<ContentDocumentLink>>();
        List<ContentDocumentLink> contentLinks = [
            SELECT Id, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :docIds
        ];
        
        for (ContentDocumentLink link : contentLinks) {
            if (!docLinksMap.containsKey(link.LinkedEntityId)) {
                docLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
            }
            docLinksMap.get(link.LinkedEntityId).add(link);
        }
        
        for (Documento__c doc : newDocs) {
            Documento__c oldDoc = oldDocs.get(doc.Id);
            
            if (oldDoc == null || doc.StatusAprovacao__c != oldDoc.StatusAprovacao__c) {
                if (doc.StatusAprovacao__c != 'Não Entregue') {
                    if (!verificarDocumentosAnexados(doc.Oportunidade__c, docLinksMap)) {
                        doc.Entregue__c = false;
                        doc.addError('Não é possível atribuir o status sem documentos anexados.');
                    } else {
                        doc.Entregue__c = true;
                    }
                }
            }
            
            if (!verificarDocumentosAnexados(doc.Oportunidade__c, docLinksMap)) {
                doc.Entregue__c = false;
            }
        }
    }

    public static void updateStatusDeleted(List<ContentDocument> oldContentDocuments) {

        Set<Id> documentIds = new Set<Id>();
        for (ContentDocument doc : oldContentDocuments) {
            documentIds.add(doc.Id);
        }

        List<ContentDocumentLink> cdls = ContentDocumentLinkSelector.obterLinksDocumentosPorContentDocId(documentIds);
        Set<Id> setLinkedEntityId = new Set<Id>();
        for (ContentDocumentLink cdl : cdls) {
            setLinkedEntityId.add(cdl.LinkedEntityId);
        }
        
        List<Documento__c> documentos = DocumentoSelector.obterDocumentosPorIds(setLinkedEntityId);

        for (Documento__c doc : documentos) {
            doc.StatusAprovacao__c = 'Não Entregue';
            doc.Entregue__c = false;
            
        }

        update documentos;
    }


    public static Boolean verificarDocumentosAnexados(Id oportunidadeId, Map<Id, List<ContentDocumentLink>> docLinksMap) {
        List<Documento__c> documentos = [
            SELECT Id
            FROM Documento__c
            WHERE Oportunidade__c = :oportunidadeId
        ];
        
        if (documentos.isEmpty()) {
            return false;
        }
        
        for (Documento__c doc : documentos) {
            if (docLinksMap.containsKey(doc.Id) && !docLinksMap.get(doc.Id).isEmpty()) {
                return true;
            }
        }
        return false;
    }
}