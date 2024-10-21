public with sharing class ContentDocumentService {
    @AuraEnabled(cacheable=false)
    public static Id uploadFile(String base64 , String fileName, String linkEntityId, String fileType) {

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.firstPublishLocationId = linkEntityId;

        insert cv;
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    }
}