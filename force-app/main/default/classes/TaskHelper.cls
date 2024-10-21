public with sharing class TaskHelper {

    private static final List<String> CONTROLE_CADENCIA_VALUES = ObjectHelper.getPickListValuesList('Lead', 'ControleCadencia__c');

    public static void handleBeforeInsert(List<Task> tasks) {
        List<Task> contactTasks = new List<Task>();

        for (Task iTask : tasks) {
            if (iTask.Subject != 'Reiteração') {
                contactTasks.add(iTask);
            }
        }

        verifyOpenTasks(contactTasks);
    }

    public static void handleAfterUpdate(List<Task> tasks) {
        List<Task> contactTasks = new List<Task>();

        for (Task iTask : tasks) {
            if (iTask.Subject != 'Reiteração') {
                contactTasks.add(iTask);
            }
        }

        countContactsTasks(contactTasks);
    }

    public static void handleAfterInsert(List<Task> tasks) {
        List<Task> reiterationTasks = new List<Task>();
        List<Task> contactTasks = new List<Task>();

        for (Task iTask : tasks) {
            if (iTask.Subject == 'Reiteração') {
                reiterationTasks.add(iTask);
            } else {
                contactTasks.add(iTask);
            }
        }

        ActivityHelper.updateTotalLeadActivities(tasks);
        updateReiterationCounter(reiterationTasks);
        countContactsTasks(contactTasks);
    }

    public static void handleAfterDelete(List<Task> tasks) {
        List<Task> contactTasks = new List<Task>();

        for (Task iTask : tasks) {
            if(iTask.Subject != 'Reiteração') {
                contactTasks.add(iTask);
            }
        }
        
        ActivityHelper.updateTotalLeadActivities(tasks);
        countContactsTasks(contactTasks);
    }

    private static void countContactsTasks(List<Task> tasks) {
        Set<Id> idLeads = ObjectHelper.getLookUpId(tasks, 'WhoId');

        List<Lead> leads = LeadDA.getLeadsById(new Set<String>{'Id', 'ControleCadencia__c'}, idLeads);

        Map<Id, List<Task>> taskMap = ActivityHelper.getActivitiesByWhoIdMap(
            TaskDA.getContactTasksByWhoId(new Set<String>{'WhoId', 'Status'}, idLeads)
        );

        Id idQueueLostLeads = [SELECT Id FROM Group WHERE DeveloperName = 'LeadsPerdidos' LIMIT 1].Id;

        for(Lead iLead : leads) {
            List<Task> leadTasks = taskMap.get(iLead.Id);
            
            if (leadTasks == null) {
                iLead.ControleCadencia__c = CONTROLE_CADENCIA_VALUES.get(0);
                continue;
            }

            Integer qtdTarefasAbertas = leadTasks.size();
                if(qtdTarefasAbertas <= 5) {
                    iLead.ControleCadencia__c = CONTROLE_CADENCIA_VALUES.get(qtdTarefasAbertas);
                    
                    if(qtdTarefasAbertas == 5) {
                        iLead.Status = 'Lost';
                        iLead.OwnerId = idQueueLostLeads;
                        iLead.MotivoLeadPerdido__c = 'Impossível Contactar';
                    }
                }
        }
        
        update leads;
    }

    private static void verifyOpenTasks(List<Task> tasks) {
        Set<Id> idLeads = ObjectHelper.getLookUpId(tasks, 'WhoId');

        Map<Id, List<Task>> taskMap = ActivityHelper.getActivitiesByWhoIdMap(
            TaskDA.getContactTasksByWhoIdAndStatus(new Set<String>{'WhoId', 'Status', 'Subject'}, idLeads, 'Open')
        );

        for (Task iTask : tasks) {
            if (taskMap.containsKey(iTask.WhoId)) {
                iTask.addError('Não é possível criar uma tarefa de contato pois já há uma tarefa em aberto.');
            }
        }
    }

    private static void updateReiterationCounter(List<Task> tasks) {
        Set<Id> idLeads = ObjectHelper.getLookUpId(tasks, 'WhoId');
    
        Map<Id, List<Task>> tasksMappedByWhoId = ActivityHelper.getActivitiesByWhoIdMap(
            TaskDA.getTasksReiteracaoByWhoId(
                new Set<String>{'WhoId'},
                idLeads
            )
        );
    
        List<Lead> leads = LeadDA.getLeadsById(new Set<String>{'Id', 'QuantidadeDeReiteracoes__c'}, idLeads);
    
        for(Lead iLead : leads) {
            if(tasksMappedByWhoId.containsKey(iLead.Id)) {
                Integer size = tasksMappedByWhoId.get(iLead.Id).size();
                iLead.QuantidadeDeReiteracoes__c = size;
            }
        }
    
        update leads;
    }
}