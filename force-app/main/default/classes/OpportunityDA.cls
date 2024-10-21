public without sharing class OpportunityDA {
    
    public static List<Opportunity> getOpportunityByAccountProduct(Id accountId, Id productId, Id responsavelId, Id corretorId) {
        return [
            SELECT
                Id,
                AccountId,
                Unidade__c,
                ResponsavelPeloLead__c,
                Corretor__c,
                StageName
            FROM Opportunity
            WHERE
                AccountId = :accountId
                AND Unidade__c = :productId
                AND (ResponsavelPeloLead__c = :responsavelId
                OR Corretor__c = :corretorId)
        ];
    }
}