public class QuoteDA {
    public static List<Quote> getQuotesById(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM Quote WHERE Id IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}