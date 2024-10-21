public class DocumentosChecklistSelector {
    @AuraEnabled(cacheable=true)
    public static List<ConfiguracaoChecklistDocumentos__mdt> buscarConfiguracoesDocumentosChecklist() {
        return [SELECT Ativo__c, CampoConta__c, TipoDocumento__c, LabelCampo__c FROM ConfiguracaoChecklistDocumentos__mdt];
    }

    public static List<ExtensoesDocumentosChecklist__mdt> buscarExtensoesPermitidasDocumentosChecklist() {
        return [SELECT Extensao__c FROM ExtensoesDocumentosChecklist__mdt];
    }
}