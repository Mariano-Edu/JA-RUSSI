public class TabelaComissaoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        TabelaComissaoHelper.handleBeforeInsert(Trigger.new);
    }
}