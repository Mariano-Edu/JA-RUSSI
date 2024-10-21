public with sharing class CompradorController {
    @AuraEnabled(cacheable=true)
    public static List<Comprador__c> getCompradorListByOpportunityId(String OppId){
        return CompradorSelector.getCompradorListByOpportunityId(OppId);
    }
}