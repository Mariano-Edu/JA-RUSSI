public class OpportunityTeamMemberService {
    public static List<OpportunityTeamMember> getEquipeVendasPadrao(Id idOpp, Id idTabelaComissao) {
        Map<String,OpportunityTeamMember> membros = getMembrosPorCargo(idOpp);
        Map<String,HierarquiaComissao__c> hierarquias = HierarquiaComissaoService.getHierarquiasByTabelaComissao(idTabelaComissao);
        List<OpportunityTeamMember> equipeVendas = new List<OpportunityTeamMember>();

        for(String cargo : hierarquias.keySet()) {
            HierarquiaComissao__c hierarquia = hierarquias.get(cargo);
            OpportunityTeamMember membro = membros.get(cargo);
            membro.PercentualComissao__c = hierarquia.PercentualComissao__c;
            membro.ValorComissao__c = hierarquia.ValorComissao__c;
            membro.ValorPremio__c = hierarquia.ValorPremio__c;
            equipeVendas.add(membro);
        }

        return equipeVendas;
    }

    public static List<OpportunityTeamMember> getMembrosToDelete(Id idOpp) {
        return OpportunityTeamMemberSelector.getOpportunityTeamMemberByOpportunity(IdOpp);
    }

    private static Map<String,OpportunityTeamMember> getMembrosPorCargo(Id idOpp) {
        List<OpportunityTeamMember> membros = OpportunityTeamMemberSelector.getOpportunityTeamMemberByOpportunity(IdOpp);
        Map<String,OpportunityTeamMember> membrosPorCargo = new Map<String,OpportunityTeamMember>();

        for(OpportunityTeamMember membro : membros) {
            membrosPorCargo.put(membro.TeamMemberRole, membro);
        }

        return membrosPorCargo;
    }
}