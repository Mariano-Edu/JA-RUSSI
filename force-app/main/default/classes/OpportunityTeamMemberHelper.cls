public class OpportunityTeamMemberHelper {
    
    public static void buildOppTeam(List<Opportunity> opportunities) {
        List<User> diretor = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Diretor_Comercial' AND IsActive = true LIMIT 1];
        List<User> gerente = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Gerente' AND IsActive = true LIMIT 1];

        List<OpportunityTeamMember> newTeamMembers = new List<OpportunityTeamMember>();
        for(Opportunity iOpp : opportunities) {

            if(!gerente.isEmpty()) {
                newTeamMembers.add(
                    new OpportunityTeamMember(
                        TeamMemberRole = 'Gerente de vendas',
                        UserId = gerente[0].Id,
                        OpportunityId = iOpp.Id
                    )
                );
            }

            if(!diretor.isEmpty()) {
                newTeamMembers.add(
                    new OpportunityTeamMember(
                        TeamMemberRole = 'Diretor Comercial',
                        UserId = diretor[0].Id,
                        OpportunityId = iOpp.Id
                    )
                );
            }

            if(iOpp.ResponsavelPeloLead__c != null) {
                newTeamMembers.add(
                    new OpportunityTeamMember(
                        TeamMemberRole = 'SDR',
                        UserId = iOpp.ResponsavelPeloLead__c,
                        OpportunityId = iOpp.Id
                    )
                );
            }
        }

        insert newTeamMembers;
    }
}