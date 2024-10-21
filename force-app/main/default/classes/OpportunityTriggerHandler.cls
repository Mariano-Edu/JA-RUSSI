public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        OpportunityHelper.handleBeforeUpdate(Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);
        OpportunityHelper.validateDoc(Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);
        OpportunityHelper.createAnaliseCredito(Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);
    }

    public override void beforeInsert() {
        OpportunityHelper.handleNewOpportunities(Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);
        OpportunityHelper.validateDoc(Trigger.new, (Map<Id,Opportunity>) Trigger.oldMap);

    }

    public override void afterInsert() {
        OpportunityTeamMemberHelper.buildOppTeam(Trigger.new);
        CriacaoDocumentosService.criarDocumentosEmCriacaoDeOportunidade((List<Opportunity>) Trigger.new);
    }
}