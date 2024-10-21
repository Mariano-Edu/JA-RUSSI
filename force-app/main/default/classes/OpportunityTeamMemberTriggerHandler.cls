public with sharing class OpportunityTeamMemberTriggerHandler extends TriggerHandler{
    
    public override void beforeUpdate(){
        OpportunityTeamMemberDomain.checkUserRoleOnModification((List<OpportunityTeamMember>) Trigger.new, (List<OpportunityTeamMember>) Trigger.old);
        
    }
    
    public override void beforeInsert(){
        OpportunityTeamMemberDomain.checkUserRoleOnModification((List<OpportunityTeamMember>) Trigger.new, (List<OpportunityTeamMember>) Trigger.old);
        
    }
    
    // public override void afterInsert() {
    //     CommissionDistributionService.distributeCommissionToOppTeamMembers(Trigger.new);
    // }

    // public override void afterDelete() {
    //     CommissionDistributionService.distributeCommissionToOppTeamMembers(Trigger.old);
    // }
    
}