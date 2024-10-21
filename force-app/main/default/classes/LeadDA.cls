public class LeadDA {
    public static List<Lead> getLeadsById(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM Lead WHERE Id IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static List<Lead> getLeadsByLastName(Set<String> fields, Set<String> lastNames) {
        return Database.query(String.format(
            'SELECT {0} FROM Lead WHERE LastName IN :lastNames',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static void updateLeads(List<Lead> leads) {
        if(leads == null || leads.isEmpty()) return;
        update leads;
    }

    public static void updateLead(Lead lead) {
        if(lead == null) return;
        update lead;
    }

    public static void deleteLeads(List<Lead> leads) {
        if(leads == null || leads.isEmpty()) return;
        delete leads;
    }

    public static void insertLeads(List<Lead> leads) {
        if(leads == null || leads.isEmpty()) return;
        insert leads;
    }
}