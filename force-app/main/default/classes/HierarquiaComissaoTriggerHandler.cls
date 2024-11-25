public class HierarquiaComissaoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        HierarquiaComissaoHelper.handleBeforeInsert(Trigger.new);
    }

}