public without sharing class RecordTypeSelector {
    public static List<RecordType> getRecordTypeById(Set<String> fields, Id idRecordType) {
        return Database.query(String.format(
            'SELECT {0} FROM RecordType WHERE Id = :idRecordType',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}