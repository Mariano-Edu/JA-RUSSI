@isTest
public class OpportunityTeamMemberControllerTest {
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
    static void testGetOpportunityTeamMemberByOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        Test.startTest();
        List<OpportunityTeamMember> teamMembers = OpportunityTeamMemberController.getOpportunityTeamMemberByOpportunity(opp.Id, tabelaComissao.Id);
        Test.stopTest();

        Assert.isNotNull(teamMembers, 'A lista de membros da equipe não deve ser nula.');
        Assert.isTrue(teamMembers.size() == 2, 'Deve haver exatamente 2 membros na equipe.');

        OpportunityTeamMember membro = teamMembers[0];
        Assert.isTrue(membro.TeamMemberRole == 'Diretor Comercial');
        Assert.isTrue(membro.PercentualComissao__c == 5.0, 'O percentual de comissão deve ser 5%.');
    }
}