public class QuoteTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        QuoteHelper.handleBeforeInsert(Trigger.new);
    }

    public override void afterInsert() {
        QuoteHelper.handleAfterInsert(Trigger.new);
    }

    public override void afterUpdate() {
        QuoteHelper.handleAfterUpdate(Trigger.new, (Map<Id,Quote>)Trigger.oldMap);
    }

    public override void beforeUpdate() {
        QuoteHelper.handleBeforeUpdate(Trigger.new);
    }

}