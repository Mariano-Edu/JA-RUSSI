public class MessagingSessionHelper {
    
    public static void handleSessionLeads(List<MessagingSession> sessions) {
        List<MessagingSession> sessionsWithoutLead = new List<MessagingSession>();
        List<MessagingSession> sessionsWithLead = new List<MessagingSession>();

        for(MessagingSession session : sessions) {
            if(session.LeadId == null) {
                sessionsWithoutLead.add(session);
                continue;
            }

            if(session.OwnerId.getSObjectType().toString() == 'Group') { continue; }

            sessionsWithLead.add(session);
        }

        insertLeads(sessionsWithoutLead);
        updateLeads(sessionsWithLead);
    }

    private static void insertLeads(List<MessagingSession> sessions) {
        Map<Id,MessagingEndUser> endUsersMap = new Map<Id,MessagingEndUser>(
            MessagingEndUserDA.getMessagingEndUsersById(
                new Set<String>{'Id', 'Name'},
                ObjectHelper.getLookUpId(sessions, 'MessagingEndUserId')
            )
        );

        List<Lead> leads = new List<Lead>();

        for(MessagingSession session : sessions) {
            MessagingEndUser endUser = endUsersMap.get(session.MessagingEndUserId);

            Lead lead = new Lead(
                LastName = endUser.Name,
                LeadSource = 'WhatsApp',
                MidiaAtual__c = 'WhatsApp'
            );

            leads.add(lead);
        }

        LeadDA.insertLeads(leads);

        List<Lead> insertedLeads = LeadDA.getLeadsByLastName(
            new Set<String>{'Id', 'LastName'},
            ObjectHelper.getFieldValuesFromList(endUsersMap.values(), 'Name')
        );

        Map<String,Lead> leadsMappedByEndUserName = new Map<String,Lead>();

        for(Lead iLead : insertedLeads) {
            leadsMappedByEndUserName.put(iLead.LastName, iLead);
        }

        List<MessagingSession> sessionsToUpdate = new List<MessagingSession>();

        for(MessagingSession session : sessions) {
            MessagingEndUser endUser = endUsersMap.get(session.MessagingEndUserId);
            Id idLead = leadsMappedByEndUserName.get(endUser.Name).Id;
            sessionsToUpdate.add(new MessagingSession(Id = session.Id, LeadId = idLead));
            endUser.LeadId = idLead;
        }

        update endUsersMap.values();
        update sessionsToUpdate;
    }

    private static void updateLeads(List<MessagingSession> sessions) {
        Map<Id,Lead> leadsToUpdateMap = new Map<Id,Lead>(
            LeadDA.getLeadsById(
                new Set<String>{'OwnerId'},
                ObjectHelper.getLookUpId(sessions, 'LeadId')
            )
        );

        for(MessagingSession session : sessions) {
            Lead lead = leadsToUpdateMap.get(session.LeadId);
            lead.OwnerId = session.OwnerId;
        }

        LeadDA.updateLeads(leadsToUpdateMap.values());
    }
}