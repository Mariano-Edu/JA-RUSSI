public class MessagingEndUserDA {
    
    public static List<MessagingEndUser> getMessagingEndUsersById(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM MessagingEndUser WHERE Id IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }  
}