public with sharing class ContentDocumentController {

    @AuraEnabled(cacheable=false)
    public static Id uploadFile(String base64 , String fileName, String linkEntityId, String fileType) {
        Id contentDocId = ContentDocumentService.uploadFile(base64, fileName, linkEntityId, fileType);
        return contentDocId;
    }
}