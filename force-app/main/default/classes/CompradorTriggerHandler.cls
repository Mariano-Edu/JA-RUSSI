public class CompradorTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        CriacaoDocumentosService.criarDocumentosEmCriacaoComprador((List<Comprador__c>) Trigger.new);
    }

    public override void beforeInsert() {
        CompradorHelper.getTotalPercent((List<Comprador__c>) Trigger.new);
        CompradorHelper.validarCompradorDuplicado((List<Comprador__c>) Trigger.new);
        CompradorHelper.validarCompradorPrincipal((List<Comprador__c>) Trigger.new);
        CompradorHelper.getOpportunityType((List<Comprador__c>) Trigger.new);
        CompradorHelper.getEstadoCivil((List<Comprador__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        CompradorHelper.getTotalPercent((List<Comprador__c>) Trigger.new);
        CompradorHelper.validarCompradorDuplicado((List<Comprador__c>) Trigger.new);
        CompradorHelper.validarCompradorPrincipal((List<Comprador__c>) Trigger.new);
        CompradorHelper.getOpportunityType((List<Comprador__c>) Trigger.new);
        CompradorHelper.getEstadoCivil((List<Comprador__c>) Trigger.new);
    }
}