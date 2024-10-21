public without sharing class LeadService {
    public static Map<String, String> obterMotivos() {
        Map<String, String> motivosPorValor = new Map<String, String>();
        
        for(Schema.PicklistEntry motivoPerdido : Lead.MotivoLeadPerdido__c.getDescribe().getPicklistValues()) {
            motivosPorValor.put(motivoPerdido.getValue(), motivoPerdido.getLabel());
        }
        
        return motivosPorValor;
    }

    public static void alterarStatusParaPerdido(Id idLead, String motivo) {
        Id idQueueLostLeads = [SELECT Id FROM Group WHERE DeveloperName = 'LeadsPerdidos' LIMIT 1].Id;
        Lead lead = [SELECT Id FROM Lead WHERE Id = :idLead];

        lead.Status = 'Lost';
        lead.OwnerId = idQueueLostLeads;
        lead.MotivoLeadPerdido__c = motivo;
        
        LeadDA.updateLead(lead);
    }
}