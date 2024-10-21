public class DocumentoSelector {
    @AuraEnabled
    public static Documento__c obterDocumentoPorId(Id idDocumento) {
        return [SELECT StatusAprovacao__c, StatusIcone__c, TipoDocumento__c, Name, Observacoes__c FROM Documento__c WHERE Id = :idDocumento];
    }

    public static List<Documento__c> obterDocumentosPorIds(Set<Id> idsDocumentos) {
        return [SELECT Id, StatusAprovacao__c FROM Documento__c WHERE Id IN :idsDOcumentos];
    }

    public static List<Documento__c> obterDocumentosPorComprador(Id idComprador) {
        return [SELECT Name, Obrigatorio__c, Entregue__c, TipoDocumento__c, StatusAprovacao__c, StatusIcone__c, Conta__c FROM Documento__c WHERE Comprador__c = :idComprador];
    }

    // public static List<Documento__c> obterDocumentosObrigatoriosPorOportunidade(Set<Id> idsOportunidades) {
    //     return [SELECT Name, Entregue__c, TipoDocumento__c, Comprador__r.Oportunidade__c FROM Documento__c WHERE Obrigatorio__c = true AND Comprador__r.Oportunidade__c IN :idsOportunidades];
    // }
}