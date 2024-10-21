public inherited sharing class LeadSLAHelper {
    
 public static void verifyLeadControlSLA(List<Lead> leadList, Map<Id, Lead> oldLeads) {
        if(oldLeads == null) oldLeads = new Map<Id, Lead>();
        Map<String, ConfiguracoesDeNegocio__c> mapConfiguracaoSLA = getMapConfiguracaoSLA(leadList);
        for (Lead lead : leadList) {
            if (lead.Status != 'Lost' && lead.Status != 'Unqualified'){

                    if (oldLeads.isEmpty() || lead.Status != oldLeads.get(lead.Id).Status) {
                    lead.ConfiguracaoDeSLA__c = null;
                    lead.DataHoraVencimento__c = null;
                    if (mapConfiguracaoSLA.containsKey(lead.Status)) {
                         ConfiguracoesDeNegocio__c configuracao = mapConfiguracaoSLA.get(lead.Status);
                         lead.DataHoraVencimento__c = Datetime.now().addMinutes(Integer.valueOf(configuracao.TempoDeSLA__c));
                         lead.ConfiguracaoDeSLA__c = configuracao.Id;
                    }
                }
            }
        }
    }


    public static void validateEventDate(List<Event> events){
        Set<Id> whoIds = ObjectHelper.getLookUpId(events, 'WhoId');
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, ConfiguracaoDeSLA__r.TempoDeSLA__c FROM Lead WHERE Id IN :whoIds]);

        List<Lead> leadsToUpdate = new List<Lead>();
        
        
        for (Event iEvent : events) {
            if (iEvent.EndDateTime > Datetime.now()) {
                Lead leadRecord = leadMap.get(iEvent.WhoId);
                if (leadRecord != null && leadRecord.ConfiguracaoDeSLA__r != null && leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c != null) {
                    leadRecord.DataHoraVencimento__c = iEvent.EndDateTime.addMinutes(Integer.valueOf(leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c));
                    leadsToUpdate.add(leadRecord);
                }
            }
        }
        

        TriggerHandler.bypass('LeadTriggerHandler');
        update leadsToUpdate;
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }

    public static void validateTaskDate(List<Task> tasks){
        Set<Id> whoIds = ObjectHelper.getLookUpId(tasks, 'WhoId');
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, ConfiguracaoDeSLA__r.TempoDeSLA__c, DataHoraVencimento__c FROM Lead WHERE Id IN :whoIds]);

        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Task iTask : tasks) {
            if (iTask.ActivityDate > Date.today()) {
                Lead leadRecord = leadMap.get(iTask.WhoId);

                if (leadRecord != null && leadRecord.ConfiguracaoDeSLA__r != null && leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c != null) {
                    Datetime dataHoraTask = Datetime.newInstance(
                        iTask.ActivityDate.year(),
                        iTask.ActivityDate.month(),
                        iTask.ActivityDate.day()
                    );

                    leadRecord.DataHoraVencimento__c = dataHoraTask.addMinutes((Integer)(leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c));

                    leadsToUpdate.add(leadRecord);
                }
            }
        }

        TriggerHandler.bypass('LeadTriggerHandler');
        update leadsToUpdate;
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }

    private static Map<String, ConfiguracoesDeNegocio__c> getMapConfiguracaoSLA(List<Lead> pLstLead) {
        Set<String> setStatus = new Set<String>();
        for (Lead lead : pLstLead) {
            setStatus.add(lead.Status);
        }
        return getMapConfiguracaoSLA(setStatus);
    }

    private static Map<String, ConfiguracoesDeNegocio__c> getMapConfiguracaoSLA(Set<String> pSetStatus) {
        Map<String, ConfiguracoesDeNegocio__c> result = new Map<String, ConfiguracoesDeNegocio__c>();
        List<ConfiguracoesDeNegocio__c> lstResult = [
            SELECT Id, Fase__c, TempoDeSLA__c
            FROM ConfiguracoesDeNegocio__c
            WHERE Fase__c IN :pSetStatus AND RecordType.DeveloperName = 'controleSLA'
        ];
        for (ConfiguracoesDeNegocio__c iResult : lstResult) {
            result.put(iResult.Fase__c, iResult);
        }
        return result;
    }

}