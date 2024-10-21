public with sharing class OpportunityTeamMemberDomain {

    public static Map<Id, List<OpportunityTeamMember>> divideOppTeamMembersByOpportunity(List<OpportunityTeamMember> oppTeamMembers) {
        Map<Id, List<OpportunityTeamMember>> oppTeamMap = new Map<Id, List<OpportunityTeamMember>>();
        
        for (OpportunityTeamMember teamMember : oppTeamMembers) {
            Id opportunityId = teamMember.OpportunityId;
            
            if (!oppTeamMap.containsKey(opportunityId)) {
                oppTeamMap.put(opportunityId, new List<OpportunityTeamMember>());
            }
            
            oppTeamMap.get(opportunityId).add(teamMember);
        }
        
        return oppTeamMap;
    }


    public static void checkUserRoleOnModification(List<OpportunityTeamMember> newOTMs, List<OpportunityTeamMember> oldOTMs) {
        if (System.userInfo.getUserRoleId() == null) return;
         
        String roleName = [SELECT DeveloperName FROM UserRole WHERE Id = :System.userInfo.getUserRoleId() LIMIT 1].DeveloperName;
        
        for(OpportunityTeamMember otm : newOTMs){
            if(roleName != 'Gerente' && roleName != 'Diretor_Comercial') { 
                otm.addError('Você não pode adicionar um membro ' + otm.TeamMemberRole ); 
            }
        }
    }
}