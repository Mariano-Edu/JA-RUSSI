public with sharing class LeadAPIHelper {

    private static final Id REITERACAO_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName()
    .get('Reiteração')
    .getRecordTypeId();

    private static final String LEAD_API_NAME = 'Lead';

    public static void handleReiteration(Map<Id, Lead> oldLeads){
        System.debug(oldLeads);
        Map<Id, Lead> mapBaseLeads = new Map<Id, Lead>(
            LeadDA.getLeadsById(
                ObjectHelper.getFieldSet(LEAD_API_NAME),
                oldLeads.keySet()
            )
        );

        LeadAPIHelper.setIterationFields(oldLeads.values());
        updateReiteratedLeads(oldLeads, mapBaseLeads);
        handleReiterationTasks(oldLeads, mapBaseLeads);
    }

    public static void setIterationFields(List<Lead> leads) {
        for(Lead iLead : leads){
            iLead.DataUltimaReiteracao__c = Datetime.now();
        }
    }

    public static List<EmpreendimentoResponse> getEmpreendimentosResponse() {
        List<EmpreendimentoResponse> empreendimentosResponse = new List<EmpreendimentoResponse>();

        for(Empreendimento__c e : [SELECT Id, Name FROM Empreendimento__c]) {
            empreendimentosResponse.add(new EmpreendimentoResponse(e));
        }

        return empreendimentosResponse;
    } 

    //Reiteração
    private static void updateReiteratedLeads(Map<Id, Lead> oldLeads, Map<Id, Lead> mapBaseLeads) {
        
        List<Lead> lstLeadToAdd = new List<Lead>();
        for(Lead iLead : oldLeads.values()){
            
            if (!String.isEmpty(iLead.Campanha__c) && mapBaseLeads.get(iLead.Id).Campanha__c != iLead.Campanha__c) {
                lstLeadToAdd.add(iLead);
            }
        }
        
        update oldLeads.values();
        CampaignResource.registerCampaign(lstLeadToAdd);
    }

    private static void handleReiterationTasks(Map<Id, Lead> newLeads, Map<Id, Lead> mapBaseLeads){
        fillRequiredTaskFields(newLeads, mapBaseLeads);
        Map<Id, List<Task>> reiterationTaskMap = getReiteracaoTaskMap(newLeads.keySet());
        List<Task> reiterationTasks = new List<Task>();

        for(Lead iLead : newLeads.values()){
            reiterationTasks.add(
                new Task(
                    RecordTypeId = REITERACAO_RECORD_TYPE_ID,
                    WhoId = iLead.Id,
                    OwnerId = iLead.OwnerId,
                    Subject = 'Reiteração',
                    ActivityDate = Date.today().addDays(1),
                    Status = reiterationTaskMap.containsKey(iLead.Id) ? 'Completed' : 'Not Started',
                    Email__c = iLead.Email,
                    Nome__c = iLead.LastName,
                    OrigemLead__c = iLead.LeadSource,
                    Midia__c = iLead.MidiaAtual__c,
                    DataHoraInteracao__c = Datetime.now(),
                    Celular__c = iLead.Celular__c == null ? null : '+' + iLead.DDICelular__c.replaceAll('\\D+','') + ' (' + iLead.DDDCelular__c + ') ' + iLead.Celular__c,
                    EmpreendimentoInteresse__c = iLead.EmpreendimentoInteresse__c,
                    Campanha__c = iLead.Campanha__c
                )
            );
        }
        
        insert reiterationTasks;
    }

    private static void fillRequiredTaskFields(Map<Id, Lead> newLeads, Map<Id, Lead> mapBaseLeads) {
        for (Lead iLead : newLeads.values()) {
            iLead.OwnerId = iLead.OwnerId ?? mapBaseLeads.get(iLead.Id).OwnerId;
            iLead.Email = iLead.Email ?? mapBaseLeads.get(iLead.Id).Email;
            iLead.LastName = iLead.LastName ?? mapBaseLeads.get(iLead.Id).LastName;
            iLead.LeadSource = iLead.LeadSource ?? mapBaseLeads.get(iLead.Id).LeadSource;
            iLead.MidiaOriginal__c = iLead.MidiaOriginal__c ?? mapBaseLeads.get(iLead.Id).MidiaOriginal__c;
            iLead.DDICelular__c = iLead.DDICelular__c ?? mapBaseLeads.get(iLead.Id).DDICelular__c;
            iLead.DDDCelular__c = iLead.DDDCelular__c ?? mapBaseLeads.get(iLead.Id).DDDCelular__c;
            iLead.Celular__c = iLead.Celular__c ?? mapBaseLeads.get(iLead.Id).Celular__c;
            iLead.EmpreendimentoInteresse__c = iLead.EmpreendimentoInteresse__c ?? mapBaseLeads.get(iLead.Id).EmpreendimentoInteresse__c;
        }
    }

    private static Map<Id, List<Task>> getReiteracaoTaskMap(Set<Id> idLeads){
        List<Task> reiterationTasks = TaskDA.getTasksReiteracaoNaoIniciadoByWhoId(
        new Set<String>{'Id', 'Status', 'WhoId'},
        idLeads
        );

        Map<Id, List<Task>> reiterationTaskMap = new Map<Id, List<Task>>();

        for(Task iTask : reiterationTasks){
            List<Task> taskList = new List<Task>();

            if(reiterationTaskMap.containsKey(iTask.WhoId)) taskList = reiterationTaskMap.get(iTask.WhoId);

            taskList.add(iTask);
            reiterationTaskMap.put(iTask.WhoId, taskList);
        }

        return reiterationTaskMap;
    }
}