public class CompradorSelector {
    public static List<Comprador__c> obterCompradoresPorOportunidade(Id idOportunidade) {
        return [SELECT Conta__r.Name FROM Comprador__c WHERE Oportunidade__c = :idOportunidade];
    }
    
    public static List<Comprador__c> obterCompradoresPrincipaisPorOportunidades(Set<Id> setIdOportunidades) {
        return [SELECT Conta__r.Name, Oportunidade__r.Name, CompradorPrincipal__c FROM Comprador__c WHERE Oportunidade__c IN :setIdOportunidades AND CompradorPrincipal__c = 'Sim'];
    }
    
    public static List<Comprador__c> obterCompradorPorIdConta(Id idConta, Id idOportunidade) {
        return [SELECT Conta__r.Name, Oportunidade__c FROM Comprador__c WHERE Conta__c = :idConta AND Oportunidade__c = :idOportunidade];
    }

    public static List<Comprador__c> getCompradorListByOpportunityId(String OppId){
        return [SELECT Id, Name FROM Comprador__c WHERE Oportunidade__c = :OppId];
    }
}