public with sharing class TabelaDeComissaoDomain {
    public static void handleBeforeUpdate(List<TabelaDeComissao__c> newTables, Map<Id, TabelaDeComissao__c> oldTables) {
        for (TabelaDeComissao__c newTable : newTables) {
            handleIndicacaoChange(newTable, oldTables.get(newTable.Id));
        }
    }
    
    public static void handleIndicacaoChange(TabelaDeComissao__c newTable, TabelaDeComissao__c oldTable) {
        if (newTable.Indication__c != oldTable.Indication__c) {
            Map<Id, Id> OTMUniques = new Map<Id, Id>();
            for (OpportunityTeamMember otm : [
            SELECT 
                Id,
                OpportunityId
            FROM 
                OpportunityTeamMember 
            WHERE 
                User.SalesChannel__c = :newTable.SalesChannel__c
            ORDER BY 
                CreatedDate 
                    ASC
            ]) {
                if(!OTMUniques.containsKey(otm.OpportunityId)) {
                    OTMUniques.put(otm.OpportunityId, otm.Id);
                }
            }
            if(!OTMUniques.isEmpty()) {
                List<Opportunity> opps = [
                SELECT 
                    Id,
                    TotalValuePlusReferral__c,
                    Amount
                FROM 
                    Opportunity 
                WHERE 
                    Id IN :OTMUniques.keySet()
            ];
                
                for (Opportunity opp : opps) {
                    Decimal referralValue = opp.Amount * (newTable.Indication__c / 100);
                    opp.TotalValuePlusReferral__c = opp.Amount + referralValue;
                }
                
                update opps;
            }
        }
    }
}