public class OpportunityTeamMemberSelector {
    public static List<OpportunityTeamMember> getOpportunityTeamMemberByOpportunity(Id idOpp) {
        return [
            SELECT
                Id,
                UserId,
                User.Name,
                TeamMemberRole,
                OpportunityId
            FROM OpportunityTeamMember
            WHERE OpportunityId = :idOpp
        ];
    }
}