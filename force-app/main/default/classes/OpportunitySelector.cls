public without sharing class OpportunitySelector {
    public static Opportunity obterOportunidadePorId(Id idOportunidade) {
        return [ 
            SELECT 
                Id, Name, TipoVenda__c, CloseDate, Owner.Name, Account.Name, EmpreendimentodeInteresse__c
            FROM Opportunity 
            WHERE 
                Id = :idOportunidade];
    }

    public static Opportunity obterOportunidadePorIdCotacao (Id idCotacao) {

        Id idOportunidade = [SELECT OpportunityId FROM Quote WHERE Id = :idCotacao LIMIT 1].OpportunityId;

        return obterOportunidadePorId(idOportunidade);
    }
}