public with sharing class ActivityHelper {
    
    public static void updateTotalLeadActivities(List<SObject> activities) {
        Map<Id, List<Event>> activitiesMappedByLeadId = getActivityMap(activities);

        List<Lead> leads = LeadDA.getLeadsById(
            new Set<String>{'Id', 'TotalDeAtividadesFaseAtual__c'},
            activitiesMappedByLeadId.keySet()
        );

        for(Lead iLead : leads) {
            iLead.TotalDeAtividadesFaseAtual__c = activitiesMappedByLeadId.get(iLead.Id).size();
        }

        update leads;
    }
    
    public static Map<Id, List<SObject>> getActivitiesByWhoIdMap(List<SObject> activities) {
        Map<Id, List<SObject>> activityMap = new Map<Id, List<SObject>>();

        for(SObject iActivity : activities) {

            List<SObject> activitiesListMap = activityMap.containsKey((Id) iActivity.get('WhoId')) 
                ? activityMap.get((Id) iActivity.get('WhoId')) 
                : new List<SObject>();

            activitiesListMap.add(iActivity);
            activityMap.put((Id) iActivity.get('WhoId'), activitiesListMap);
        }

        return activityMap;
    }

    private static Map<Id, List<Event>> getActivityMap(List<SObject> activities){
        Map<Id, List<SObject>> activitiesMappedByLeadId = new Map<Id, List<SObject>>();
        Set<Id> idLeads = ObjectHelper.getLookUpId(activities, 'WhoId');

        for(Id idLead : idLeads) activitiesMappedByLeadId.put(idLead, new List<SObject>());

        List<SObject> leadsActivities = new List<SObject>();

        leadsActivities.addAll(TaskDA.getTasksByWhoId(new Set<String>{'Id', 'WhoId'}, idLeads));
        leadsActivities.addAll(EventDA.getEventByWhoId(new Set<String>{'Id', 'WhoId'}, idLeads));

        for(SObject iActivity : leadsActivities){
            List<SObject> activityList = activitiesMappedByLeadId.get((Id) iActivity.get('WhoId'));
            activityList.add(iActivity);
            activitiesMappedByLeadId.put((Id) iActivity.get('WhoId'), activityList);
        }
        
        return activitiesMappedByLeadId;
    }
}