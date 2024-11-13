public with sharing class OpportunityController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity obterOportunidadePorId(Id idOportunidade) {
        return OpportunitySelector.obterOportunidadePorId(idOportunidade);
    }
    
    @AuraEnabled(cacheable=true)
    public static Opportunity obterOportunidadePorIdCotacao(Id idCotacao) {
        return OpportunitySelector.obterOportunidadePorIdCotacao(idCotacao);
    }
}