public with sharing class HierarquiaDaComissaoTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        CommissionDistributionService.distributeCommissionHierarchiesToOppTeamMembers(Trigger.new);
    }
    
    public override void afterUpdate() {
        CommissionDistributionService.distributeCommissionHierarchiesToOppTeamMembers(Trigger.new);
    }

    public override void beforeDelete() {
        CommissionDistributionService.distributeCommissionHierarchiesToOppTeamMembers(
            CommissionDistributionService.removeCommissionFromCommissionHierarchiesObjects(Trigger.old)
        );
    }
}