public class HierarquiaComissaoDA {
    public static List<HierarquiaComissao__c> getHierarquiaComissaoByTabela(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM HierarquiaComissao__c WHERE TabelaComissao__c IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}