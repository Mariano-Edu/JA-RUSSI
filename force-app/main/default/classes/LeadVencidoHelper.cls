public with sharing class LeadVencidoHelper {

    private static LeadVencidoHelper instance = new LeadVencidoHelper();
    public static LeadVencidoHelper getInstance(){
        return instance;
    }

    public void atualizaLeadVencido(List<Lead> leads) {
        Map<String, Id> filaNameToIdMap = new Map<String, Id>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : leads) {
            if (!String.isEmpty(lead.ConfiguracaoDeSLA__c) && !String.isEmpty(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c)) {
                filaNameToIdMap.put(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c, null);
            }
        }

        if (!filaNameToIdMap.isEmpty()) {
            for (Group fila : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :filaNameToIdMap.keySet()]) {
                filaNameToIdMap.put(fila.Name, fila.Id);
            }
        }

        for (Lead lead : leads) {
            Lead leadUpdate = new Lead();
            Boolean updateLead = false;
            leadUpdate.Id = lead.Id;
            if (filaNameToIdMap.containsKey(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c)) {
                leadUpdate.OwnerId = filaNameToIdMap.get(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c);
                updateLead = true;
            }

            if (!String.isEmpty(lead.ConfiguracaoDeSLA__c)) {
                leadUpdate.Status = lead.ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c;
                System.debug(lead.ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c);
                updateLead = true;
            }
            if(updateLead) leadsToUpdate.add(leadUpdate);
        }

        if(leadsToUpdate.isEmpty()) return;

        TriggerHandler.bypass('LeadTriggerHandler');
        
        update leadsToUpdate;

        TriggerHandler.clearBypass('LeadTriggerHandler');

    }
}