public class ContentDocumentLinkSelector {
    public static List<ContentDocumentLink> obterLinksDocumentosPorId(Set<Id> idsLinks) {
        return [SELECT ContentDocument.FileType, LinkedEntity.RecordTypeId, LinkedEntityId FROM ContentDocumentLink WHERE Id IN :idsLinks];
    }

    public static List<ContentDocumentLink> obterLinksDocumentosPorContentDocId(Set<Id> ids) {
        return [SELECT ContentDocument.FileType, LinkedEntity.RecordTypeId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :ids];
    }

    @AuraEnabled
    public static List<ContentDocumentLink> obterLinksDocumentosPorLinkedEntityId(Id linkedEntityId) {
        return [SELECT ContentDocument.FileType, ContentDocument.Title, ContentDocumentId, ContentDocument.Owner.Name, ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId, ContentDocument.LastModifiedDate FROM ContentDocumentLink WHERE LinkedEntityId = :linkedEntityId];
    }

    
    public static List<ContentDocumentLink> buscarLinksDocumentosPorSetLinkedEntityId(Set<Id> linkedEntitiesIds) {
        return [SELECT ContentDocument.FileType, ContentDocument.Title, ContentDocumentId, ContentDocument.Owner.Name, ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId, LinkedEntityId, ContentDocument.LastModifiedDate FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntitiesIds];
    }
}