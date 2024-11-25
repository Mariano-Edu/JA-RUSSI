public class OpportunityTeamMemberController {
    @AuraEnabled(cacheable = true)
    public static List<OpportunityTeamMember> getOpportunityTeamMemberByOpportunity(Id idOpp, Id idTabelaComissao) {
        return OpportunityTeamMemberService.getEquipeVendasPadrao(IdOpp, idTabelaComissao);
    }
}