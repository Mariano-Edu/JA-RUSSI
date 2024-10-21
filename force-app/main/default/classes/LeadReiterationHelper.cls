public class LeadReiterationHelper {

    private static final Id REITERACAO_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByName()
        .get('Reiteração')
        .getRecordTypeId();

    public static void handleReiteration(List<Lead> leads) {
        Map<Id,Lead> reiteratedLeads = findDuplicateRecords(leads);
        if(reiteratedLeads.isEmpty()) { return; }
        Map<Id,Lead> mapBaseLeads = new Map<Id,Lead>(
            LeadDA.getLeadsById(
                ObjectHelper.getFieldSet('Lead'),
                reiteratedLeads.keySet()
            )
        );
        setIterationFields(reiteratedLeads.values());
        LeadDA.updateLeads(reiteratedLeads.values());
        handleReiterationTasks(reiteratedLeads, mapBaseLeads);
    }
    
    private static void setIterationFields(List<Lead> leads) {
        for(Lead iLead : leads) {
            iLead.DataUltimaReiteracao__c = Datetime.now();
        }
    }
    private static void handleReiterationTasks(Map<Id,Lead> newLeads, Map<Id,Lead> mapBaseLeads){
        fillRequiredTaskFields(newLeads, mapBaseLeads);
        Map<Id, List<Task>> reiterationTaskMap = getReiteracaoTaskMap(newLeads.keySet());
        List<Task> reiterationTasks = new List<Task>();

        for(Lead iLead : newLeads.values()) {
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

        TaskDA.insertTasks(reiterationTasks);
    }

    private static void fillRequiredTaskFields(Map<Id,Lead> newLeads, Map<Id,Lead> mapBaseLeads) {
        for (Lead iLead : newLeads.values()) {
            iLead.OwnerId = iLead.OwnerId ?? mapBaseLeads.get(iLead.Id).OwnerId;
            iLead.Email = iLead.Email ?? mapBaseLeads.get(iLead.Id).Email;
            iLead.LastName = iLead.LastName ?? mapBaseLeads.get(iLead.Id).LastName;
            iLead.LeadSource = iLead.LeadSource ?? mapBaseLeads.get(iLead.Id).LeadSource;
            iLead.MidiaOriginal__c = iLead.MidiaOriginal__c ?? mapBaseLeads.get(iLead.Id).MidiaOriginal__c;

            if(iLead.DDICelular__c != null && iLead.DDDCelular__c != null && iLead.Celular__c != null) {
                iLead.DDICelular__c = iLead.DDICelular__c ?? mapBaseLeads.get(iLead.Id).DDICelular__c;
                iLead.DDDCelular__c = iLead.DDDCelular__c ?? mapBaseLeads.get(iLead.Id).DDDCelular__c;
                iLead.Celular__c = iLead.Celular__c ?? mapBaseLeads.get(iLead.Id).Celular__c;
            }

            if(iLead.EmpreendimentoInteresse__c != null) {
                iLead.EmpreendimentoInteresse__c = iLead.EmpreendimentoInteresse__c ?? mapBaseLeads.get(iLead.Id).EmpreendimentoInteresse__c;
            }
        }
    }

    private static Map<Id, List<Task>> getReiteracaoTaskMap(Set<Id> idLeads){
        List<Task> reiterationTasks = TaskDA.getTasksReiteracaoNaoIniciadoByWhoId(
            new Set<String>{'Id', 'Status', 'WhoId'},
            idLeads
        );

        Map<Id,List<Task>> reiterationTaskMap = new Map<Id, List<Task>>();

        for(Task iTask : reiterationTasks){
            List<Task> taskList = reiterationTaskMap.containsKey(iTask.WhoId)
                ? reiterationTaskMap.get(iTask.WhoId)
                : new List<Task>();

            taskList.add(iTask);
            reiterationTaskMap.put(iTask.WhoId, taskList);
        }

        return reiterationTaskMap;
    }

    private static Map<Id,Lead> findDuplicateRecords(List<Lead> insertedLeads) {
        List<Lead> leadsToDelete = new List<Lead>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>();

        for(Lead iLead : insertedLeads.deepClone(true)){
            List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(new List<Lead>{iLead});

            for (Datacloud.FindDuplicatesResult dupeResult : duplicateResults) {
                for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {

                        for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                            Lead dupe = (Lead) matchRec.getRecord();

                            if(iLead.Id != dupe.Id) {
                                leadsToDelete.add(new Lead(Id = iLead.Id));
                                iLead.Id = dupe.Id;
                                leadMap.put(dupe.Id, iLead);
                            }
                        }
                    }
                }
            }
        }

        LeadDA.deleteLeads(leadsToDelete);
        return filterLeads(leadMap);
    }

    private static Map<Id,Lead> filterLeads(Map<Id,Lead> leadMap) {
        Map<Id,Lead> filteredLeadMap = new Map<Id,Lead>();

        for(Lead iLead : leadMap.values()) {
            Map<String,Object> leadFieldMap = new Map<String, Object>(iLead.getPopulatedFieldsAsMap());
            leadFieldMap.remove('PrimeiroEmpreendimento__c');
            leadFieldMap.remove('MidiaOriginal__c');
            leadFieldMap.remove('PrimeiraOrigem__c');
            Lead filteredLead = (Lead) JSON.deserialize(JSON.serialize(leadFieldMap), Lead.class);
            filteredLeadMap.put(iLead.Id, filteredLead);
        }

        return filteredLeadMap;
    }
}