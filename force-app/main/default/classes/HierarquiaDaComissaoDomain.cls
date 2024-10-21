public with sharing class HierarquiaDaComissaoDomain {
    
    public static Boolean isCommissionChangeIsValid(HierarquiaDaComissao__c hierachy) {
        if (hierachy.TabelaDeComissao__c == null) {
            return true;
        }

        TabelaDeComissao__c commissionTable = [
            SELECT Id, SalesChannel__c, Active__c, StartOfTerm__c, EndOfTerm__c
            FROM TabelaDeComissao__c 
            WHERE Id = :hierachy.TabelaDeComissao__c
        ];
        
        Date today = Date.today();

        if (commissionTable.Active__c && (today >= commissionTable.StartOfTerm__c && today <= commissionTable.EndOfTerm__c)) {
            Integer countOppTeamMembers = [
                SELECT COUNT() 
                FROM OpportunityTeamMember 
                WHERE User.SalesChannel__c = :commissionTable.SalesChannel__c
                    AND USer.UserRole.Name = :hierachy.Role__c
                    AND Opportunity.IsClosed = false
            ];

            if (countOppTeamMembers != 0) {
                hierachy.addError('Existem Equipes de Oportunidades em andamento atreladas a essa hierarquia. Crie uma nova Tabela/Hierarquia de Comissão.');
                return false;
            }
        }

        return true;
    }
}