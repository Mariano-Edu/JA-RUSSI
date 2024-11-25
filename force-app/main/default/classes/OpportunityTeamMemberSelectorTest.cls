@isTest
public class OpportunityTeamMemberSelectorTest {

    @TestSetup
    static void makeData(){
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Opportunity opp = TestDataFactory.gerarOportunidade(conta.Id);
        insert opp;
    }


    @isTest
    static void testGetOpportunityTeamMemberByOpportunity() {
        OpportunityTeamMember teamMember = [SELECT Id, UserId FROM OpportunityTeamMember LIMIT 1];
        Id idOpp = [SELECT Id FROM Opportunity LIMIT 1].Id;

        Test.startTest();
        List<OpportunityTeamMember> teamMembers = OpportunityTeamMemberSelector.getOpportunityTeamMemberByOpportunity(idOpp);
        Test.stopTest();

        // Assert para garantir que os dados retornados estão corretos
        Assert.areNotEqual(null, teamMembers, 'A lista de membros da equipe não deve ser nula.');
        Assert.areEqual(2, teamMembers.size(), 'Deve haver exatamente 1 membro da equipe retornado.');
        Assert.areEqual(teamMember.Id, teamMembers[0].Id, 'O membro da equipe retornado deve corresponder ao inserido.');
        Assert.areEqual(teamMember.UserId, teamMembers[0].UserId, 'O usuário do membro da equipe deve ser correto.');
        Assert.areEqual('Diretor Comercial', teamMembers[0].TeamMemberRole, 'A função do membro da equipe deve ser "Sales Rep".');
    }
}