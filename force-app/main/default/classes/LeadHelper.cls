public with sharing class LeadHelper {

    private static final List<String> STATUS_PICKLIST_VALUES = ObjectHelper.getPickListValuesList('Lead', 'Status');

    private static Id pfRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName()
            .get('Pessoa Física')
            .getRecordTypeId();

    private static Id pjRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName()
            .get('Pessoa Jurídica')
            .getRecordTypeId();

    public static void handleUpdate(List<Lead> leads, Map<Id,Lead> oldLeadsMap) {
        LeadSLAHelper.verifyLeadControlSLA(leads, oldLeadsMap); 
        resetNumberActivities(oldLeadsMap, leads);
        setFirstFields(leads);
        validatePipelineStatus(leads, oldLeadsMap);
        updateResponsavelPeloLead(leads);
    }

    private static void updateResponsavelPeloLead(List<Lead> leads) {
        for (Lead iLead : leads) {
            if (iLead.OwnerId != null && iLead.OwnerId.getSObjectType() == User.SObjectType) {
                iLead.ResponsavelPeloLead__c = iLead.OwnerId;
            }
        }
    }

    public static void handleNewLeads(List<Lead> leads) {
        assignInitialStatus(leads);
        LeadSLAHelper.verifyLeadControlSLA(leads, null);
        setLeadsRecordType(leads);
        setFirstFields(leads);
        updateResponsavelPeloLead(leads);
    }

    public static Boolean isPhoneEqual(Lead iLead, Lead jLead) {
        return String.join(
            new List<String>{
                iLead.DDITelefone__c,
                iLead.DDDTelefone__c,
                iLead.Phone
            },
            ' '
        ).equals(
            String.join(
                new List<String>{
                    jLead.DDITelefone__c,
                    jLead.DDDTelefone__c,
                    jLead.Phone
                },
                ' '
            )
        );
    }

    public static Boolean isMobilePhoneEqual(Lead iLead, Lead jLead) {
        return String.join(
            new List<String> {
                iLead.DDICelular__c,
                iLead.DDDCelular__c,
                iLead.Celular__c
            },
            ' '
        ).equals(
            String.join(
                new List<String>{
                    jLead.DDICelular__c,
                    jLead.DDDCelular__c,
                    jLead.Celular__c
                },
                ' '
            )
        );
    }

    private static void setLeadsRecordType(List<Lead> leads) {
        for(Lead iLead : leads) {
            if(iLead.RecordTypeId != null) continue;
            iLead.RecordTypeId = iLead.isPJ__c ? pjRecordTypeId : pfRecordTypeId;
        }
    }

    private static void validatePipelineStatus(List<Lead> leads, Map<Id,Lead> oldLeadsMap) {
        List<Lead> contactingStatusLeads = new List<Lead>();
        List<Lead> scheduledStatusLeads = new List<Lead>();
        List<Lead> convertedStatusLeads = new List<Lead>();

        for(Lead iLead : leads) {
            Lead oldLead = oldLeadsMap.get(iLead.Id);

            if(oldLead.Status == iLead.Status) continue;

            Integer statusGap = STATUS_PICKLIST_VALUES.indexOf(iLead.Status) - STATUS_PICKLIST_VALUES.indexOf(oldLead.Status);

            if(statusGap > 1 && oldLead.Status != 'Lost' && oldLead.Status != 'Unqualified') {
                iLead.addError('O lead pode avançar apenas uma etapa por vez');
                continue;
            }

            if(STATUS_PICKLIST_VALUES.indexOf(iLead.Status) > STATUS_PICKLIST_VALUES.indexOf(oldLead.Status)) {
                if(iLead.IsConverted) convertedStatusLeads.add(iLead);
                if(oldLead.Status == 'Contacting') contactingStatusLeads.add(iLead);
                else if(oldLead.Status == 'Scheduled') scheduledStatusLeads.add(iLead);
            }
        }

        validateContactTask(contactingStatusLeads);
        validateLeadsVisit(scheduledStatusLeads);
        validateConvertedLeadsActivities(convertedStatusLeads);
    }

    private static void assignInitialStatus(List<Lead> leads) {
        Set<Id> integrationUsersIds = new Map<Id,User>([
            SELECT 
                Id
            FROM User WHERE UserRole.DeveloperName = 'Integracao'
        ]).keySet();

        for(Lead iLead : leads) {
            if(!integrationUsersIds.contains(iLead.OwnerId)) {
                iLead.Status = 'Contacting';
            }else {
                iLead.Status = 'New';
            }
        }
    }
    
    private static void setFirstFields(List<Lead> leads){
        for(Lead iLead : leads) {
            setFirstFields(iLead, new Map<String, String>{
                'EmpreendimentoInteresse__c' => 'PrimeiroEmpreendimento__c',
                'MidiaAtual__c' => 'MidiaOriginal__c',
                'LeadSource' => 'PrimeiraOrigem__c'
            });
        }
    }

    private static void setFirstFields(Lead pLead, Map<String, String> pMapFromToFields) {
        Set<Id> setId = new Map<Id,Empreendimento__c>([
            SELECT
                Id
            FROM Empreendimento__c 
            WHERE Generico__c = true
        ]).keySet();

        for(String iFrom : pMapFromToFields.keySet()) {
            Object fromValue = pLead.get(iFrom);
            Object toValue = pLead.get(pMapFromToFields.get(iFrom));

            if (pMapFromToFields.get(iFrom) != 'PrimeiroEmpreendimento__c' && fromValue != null && toValue == null) {
                pLead.put(pMapFromToFields.get(iFrom), fromValue);
            }

            if (pLead.PrimeiroEmpreendimento__c == null && !setId.contains((Id) pLead.get('EmpreendimentoInteresse__c'))) {
                pLead.put('PrimeiroEmpreendimento__c', pLead.get('EmpreendimentoInteresse__c'));
            }
        }
    }

    private static void resetNumberActivities(Map<Id, Lead> oldLeadsMap, List<Lead> newLeads){
        for(Lead iLead : newLeads){

            if(iLead.Status != oldLeadsMap.get(iLead.Id).Status) {
                iLead.TotalDeAtividadesFaseAtual__c = 0;
                iLead.DataHoraAtualizacaoFase__c = Datetime.now();
            }
        }
    }

    private static void validateConvertedLeadsActivities(List<Lead> leads) {
        Set<Id> setContactId = ObjectHelper.getLookUpId(leads, 'ConvertedContactId');

        Map<Id,List<Task>> mapTasks = ActivityHelper.getActivitiesByWhoIdMap(
            TaskDA.getContactTasksByWhoIdAndStatus(new Set<String>{'WhoId'}, setContactId, 'Completed')  
        );

        Map<Id,List<Event>> mapEvents = ActivityHelper.getActivitiesByWhoIdMap(
            EventDA.getEventDoneByWhoId(new Set<String>{'WhoId'}, setContactId)
        );

        Set<Id> defaultEmpreendimentoSetId = new Map<Id,Empreendimento__c>([
            SELECT
                Id
            FROM Empreendimento__c 
            WHERE Generico__c = true
        ]).keySet();
                
        for(Lead iLead : leads) {
            if (defaultEmpreendimentoSetId.contains(iLead.EmpreendimentoInteresse__c)) {
                iLead.addError('O lead não pode avançar com um empreendimento genérico.');
                continue;
            }

            if(!iLead.LeadNaoQuisVisitar__c && !mapEvents.containsKey(iLead.ConvertedContactId)) {
                iLead.addError('O lead precisa ter um compromisso realizado com sucesso para ser convertido');
                continue;
            }

            if(!mapTasks.containsKey(iLead.ConvertedContactId)) 
                iLead.Status.addError('O lead não pode prosseguir para essa fase, pois não foi feito um contato');
        }
    }

    private static void validateLeadsVisit(List<Lead> leads){
        Map<Id,List<Event>> mapEvents = ActivityHelper.getActivitiesByWhoIdMap(
            EventDA.getEventDoneByWhoId(
                new Set<String>{'WhoId'},
                new Map<Id,Lead>(leads).keySet()
            )
        );

        Set<Id> defaultEmpreendimentoSetId = new Map<Id,Empreendimento__c>([
            SELECT
                Id
            FROM Empreendimento__c 
            WHERE Generico__c = true
        ]).keySet();
        
        for(Lead lead : leads) {
            if (defaultEmpreendimentoSetId.contains(lead.EmpreendimentoInteresse__c)) {
                lead.addError('O lead não pode avançar com um empreendimento genérico.');
            }

            if(!lead.LeadNaoQuisVisitar__c && !mapEvents.containsKey(lead.Id)) {
                lead.addError('O lead precisa ter um compromisso realizado com sucesso para avançar de fase');
            }
        }
    }

    private static void validateContactTask(List<Lead> leads){
        Map<Id, List<Task>> mapLeadTasks = ActivityHelper.getActivitiesByWhoIdMap(
            TaskDA.getContactTasksByWhoIdAndStatus(
                new Set<String>{'WhoId'},
                new Map<Id, Lead>(leads).keySet(),
                'Completed'
            )
        );

        for(Lead iLead : leads){
            if(!mapLeadTasks.containsKey(iLead.Id)) 
                iLead.Status.addError('O lead não pode prosseguir para essa fase, pois não foi feito um contato');
        }
    }
}