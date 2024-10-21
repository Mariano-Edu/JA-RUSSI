public with sharing class CommissionDistributionService {

    public static void distributeCommissionToOppTeamMembers(List<OpportunityTeamMember> oppTeamMembers) {
        Map<HierarquiaDaComissao__c, List<OpportunityTeamMember>> oppTeamMembersByHierarchy = new Map<HierarquiaDaComissao__c, List<OpportunityTeamMember>>();
                
        for (OpportunityTeamMember teamMember : oppTeamMembers) {
            User teamMemberUser = [
                SELECT 
                    Id, 
                    UserRoleId, 
                    UserRole.Name, 
                    SalesChannel__c 
                FROM User WHERE Id = :teamMember.UserId
            ];
            
            Date today = Date.today();

            List<HierarquiaDaComissao__c> commissionHierarchyList = [
                SELECT 
                    Id, 
                    Comission__c 
                FROM HierarquiaDaComissao__c 
                WHERE Role__c = :teamMemberUser.UserRole.Name 
                    AND TabelaDeComissao__r.SalesChannel__c = :teamMemberUser.SalesChannel__c 
                    AND TabelaDeComissao__r.Active__c = true 
                    AND TabelaDeComissao__r.StartOfTerm__c <= :today AND TabelaDeComissao__r.EndOfTerm__c >= :today
                LIMIT 1];

            if (commissionHierarchyList.size() == 0) {
                continue;
            }

            HierarquiaDaComissao__c commissionHierarchy = commissionHierarchyList.get(0);

            if (!oppTeamMembersByHierarchy.containsKey(commissionHierarchy)) {
                List<OpportunityTeamMember> oppTeamMembersInSameHierarchy = [
                    SELECT
                        Id,
                        ComissionPercentage__c,
                        OpportunityId
                    FROM OpportunityTeamMember
                    WHERE User.UserRoleId = :teamMemberUser.UserRoleId AND User.SalesChannel__c = :teamMemberUser.SalesChannel__c AND Opportunity.isClosed = false
                ];

                if (oppTeamMembersInSameHierarchy.size() > 0) {
                    oppTeamMembersByHierarchy.put(commissionHierarchy, oppTeamMembersInSameHierarchy);
                }
            }
        }

        updateOppTeamMembersByCommissionHierarchy(oppTeamMembersByHierarchy);
    }

    public static void distributeCommissionHierarchiesToOppTeamMembers(List<HierarquiaDaComissao__c> commissionHierarchies) {
        Map<HierarquiaDaComissao__c, List<OpportunityTeamMember>> oppTeamMembersByHierarchy = new Map<HierarquiaDaComissao__c, List<OpportunityTeamMember>>();

        for (HierarquiaDaComissao__c commissionHierarchy : commissionHierarchies) {
            if (HierarquiaDaComissaoDomain.isCommissionChangeIsValid(commissionHierarchy)) {
                continue;
            }

            TabelaDeComissao__c commissionTable = [
                SELECT
                    Id,
                    SalesChannel__c
                FROM TabelaDeComissao__c
                WHERE Id = :commissionHierarchy.TabelaDeComissao__c
            ];

            List<OpportunityTeamMember> oppTeamMembers = [
                SELECT
                    Id,
                    ComissionPercentage__c,
                    OpportunityId
                FROM OpportunityTeamMember
                WHERE User.UserRole.Name = :commissionHierarchy.Role__c AND User.SalesChannel__c = :commissionTable.SalesChannel__c AND Opportunity.isClosed = false
            ];

            if (oppTeamMembers.size() > 0) {
                oppTeamMembersByHierarchy.put(commissionHierarchy, oppTeamMembers);
            }
        }

        updateOppTeamMembersByCommissionHierarchy(oppTeamMembersByHierarchy);
    }

    public static void updateOppTeamMembersByCommissionHierarchy(Map<HierarquiaDaComissao__c, List<OpportunityTeamMember>> oppTeamMembersByHierarchy) {        
        List<OpportunityTeamMember> oppTeamMembersToUpdate = new List<OpportunityTeamMember>();
        List<Id> opportunitiesToUpdate = new List<Id>();
        
        for (HierarquiaDaComissao__c commissionHierarchy : oppTeamMembersByHierarchy.keySet()) {
            Map<Id, List<OpportunityTeamMember>> oppTeamMembersByOpp = OpportunityTeamMemberDomain.divideOppTeamMembersByOpportunity(oppTeamMembersByHierarchy.get(commissionHierarchy));

            for (Id opportunityId : oppTeamMembersByOpp.keySet()) {
                Decimal commissionPercentageTotal = commissionHierarchy.Comission__c;
                Decimal commissionPercentageForEachMember = commissionPercentageTotal / oppTeamMembersByOpp.get(opportunityId).size();

                for (OpportunityTeamMember teamMember : oppTeamMembersByOpp.get(opportunityId)) {
                    teamMember.ComissionPercentage__c = commissionPercentageForEachMember;
                    oppTeamMembersToUpdate.add(teamMember);
                }

                opportunitiesToUpdate.add(opportunityId);
            }
        }

        update oppTeamMembersToUpdate;
        
        updateOpportunityWithCommissionPercentageTotal(opportunitiesToUpdate);
    }

    public static List<HierarquiaDaComissao__c> removeCommissionFromCommissionHierarchiesObjects(List<HierarquiaDaComissao__c> commissionHierarchiesToDelete) {        
        List<HierarquiaDaComissao__c> commissionHierarchiesToReturn = new List<HierarquiaDaComissao__c>();

        for (HierarquiaDaComissao__c commissionHierarchy : commissionHierarchiesToDelete) {
            commissionHierarchiesToReturn.add(new HierarquiaDaComissao__c(
                Id = commissionHierarchy.Id,
                Comission__c = 0,
                Role__c = commissionHierarchy.Role__c,
                TabelaDeComissao__c = commissionHierarchy.TabelaDeComissao__c,
                Name = commissionHierarchy.Name
            ));
        }

        return commissionHierarchiesToReturn;
    }

    public static void updateOpportunityWithCommissionPercentageTotal(List<Id> opportunityIds) {
        for (Id opportunityId : opportunityIds) {
            List<OpportunityTeamMember> oppTeamMembers = [SELECT Id, ComissionPercentage__c FROM OpportunityTeamMember WHERE OpportunityId = :opportunityId];
            Decimal commissionPercentageTotal = 0;
    
            for (OpportunityTeamMember teamMember : oppTeamMembers) {
                commissionPercentageTotal += teamMember.ComissionPercentage__c ?? 0;
            }
    
            update new Opportunity(Id = opportunityId, ComissionTotalPercentage__c = commissionPercentageTotal);
        }
    }
}