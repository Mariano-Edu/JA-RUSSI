public with sharing class ViewMinutaDocumentController {

    public class DocumentDTO {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<DocumentDTO> getDocumentList(String recordId){
        List<DocumentDTO> dtoList = new List<DocumentDTO>();
        for(ContentDocumentLink cdl :  [Select Id,ContentDocument.Title,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId =: recordId]){
            DocumentDTO dto = new DocumentDTO();
            dto.label = cdl.ContentDocument.Title;
            dto.value = cdl.ContentDocumentId;
            dtoList.add(dto);
        }

        return dtoList;

    }
}