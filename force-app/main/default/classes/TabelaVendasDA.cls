public class TabelaVendasDA {
    public static List<TabelaVendas__c> getTabelaVendasById(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM TabelaVendas__c WHERE Id IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}