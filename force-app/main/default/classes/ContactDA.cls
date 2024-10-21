public with sharing class ContactDA {
    public static List<Contact> getContactsById(Set<String> fields, Set<Id> idS) {
        return Database.query(String.format(
                'SELECT {0} FROM Contact WHERE Id IN :idS',
                new String[]{String.join(new List<String>(fields), ',')}
             ));
    }
}