@isTest
public class OpportunityTeamMemberServiceTest {
    @testSetup
    static void setup() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Opportunity opp = TestDataFactory.gerarOportunidade(conta.Id);
        insert opp;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        TabelaComissao__c tabelaComissao = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas.Id, empreendimento.Id);
        insert tabelaComissao;

        insert new List<HierarquiaComissao__c> {
            new HierarquiaComissao__c(
                PercentualComissao__c = 5.0,
                TabelaComissao__c = tabelaComissao.Id,
                Cargo__c = 'Diretor Comercial'
            ),
            new HierarquiaComissao__c(
                PercentualComissao__c = 5.0,
                TabelaComissao__c = tabelaComissao.Id,
                Cargo__c = 'Gerente de vendas'
            )
        };
    }

    @isTest
    static void testGetEquipeVendasPadrao() {
        Id idOpp = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id idTabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1].Id;

        List<OpportunityTeamMember> membros = [
            SELECT
                Id,
                UserId,
                User.Name,
                TeamMemberRole,
                OpportunityId
            FROM OpportunityTeamMember
            WHERE OpportunityId = :idOpp
        ];

        List<HierarquiaComissao__c> hierarquias = [
            SELECT
                Id,
                Cargo__c,
                ValorComissao__c,
                PercentualComissao__c,
                ValorPremio__c
            FROM HierarquiaComissao__c
        ];

        Map<String,HierarquiaComissao__c> hierarquiasPorCargo = new Map<String,HierarquiaComissao__c>();

        for(HierarquiaComissao__c iHierarquia : hierarquias) {
            hierarquiasPorCargo.put(iHierarquia.Cargo__c, iHierarquia);
        }

        Map<String,OpportunityTeamMember> membrosPorCargo = new Map<String,OpportunityTeamMember>();

        for(OpportunityTeamMember iMembro : membros) {
            membrosPorCargo.put(iMembro.TeamMemberRole, iMembro);
        }

        for(String cargo : hierarquiasPorCargo.keySet()) {
            HierarquiaComissao__c hierarquia = hierarquiasPorCargo.get(cargo);
            OpportunityTeamMember membro = membrosPorCargo.get(cargo);
            membro.PercentualComissao__c = hierarquia.PercentualComissao__c;
            membro.ValorComissao__c = hierarquia.ValorComissao__c;
            membro.ValorPremio__c = hierarquia.ValorPremio__c;
            membrosPorCargo.put(cargo, membro);
        }

        Test.startTest();
        List<OpportunityTeamMember> equipeVendas = OpportunityTeamMemberService.getEquipeVendasPadrao(idOpp, idTabelaComissao);
        Test.stopTest();

        for(OpportunityTeamMember iMembro : equipeVendas) {
            Assert.areEqual(membrosPorCargo.get(iMembro.TeamMemberRole), iMembro);
        }
    }

    @isTest
    static void testGetMembrosToDelete() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityTeamMember teamMember = [SELECT Id FROM OpportunityTeamMember LIMIT 1];

        Test.startTest();
        List<OpportunityTeamMember> membrosToDelete = OpportunityTeamMemberService.getMembrosToDelete(opp.Id);
        Test.stopTest();

        Assert.areNotEqual(null, membrosToDelete, 'A lista de membros a serem deletados não deve ser nula.');
        Assert.areEqual(2, membrosToDelete.size(), 'Deve haver exatamente 1 membro retornado para exclusão.');
    }
}