public with sharing class EventDA {
    public static List<Event> getEventDoneByWhoId(Set<String> fields, Set<Id> whoIds) {
        return Database.query(String.format(
                'SELECT {0} FROM Event WHERE WhoId IN :whoIds AND StatusVisita__c = \'Done\'',
                new String[]{String.join(new List<String>(fields), ',')}
             ));
    }

    public static List<Event> getEventByWhoId(Set<String> fields, Set<Id> whoIds){
        return Database.query(String.format(
                'SELECT {0} FROM Event WHERE WhoId IN :whoIds',
                new String[]{String.join(new List<String>(fields), ',')}
             ));
    }

    public static Map<Id, Opportunity> getOpportunitiesByEventIds(Set<Id> eventIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, StageName FROM Opportunity WHERE Id IN :eventIds
        ]);
    }
}