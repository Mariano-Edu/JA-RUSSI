public class TabelaComissaoDA {
    public static List<TabelaComissao__c> getTabelaComissaoByTabelaVenda(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM TabelaComissao__c WHERE TabelaVenda__c IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static List<TabelaComissao__c> getTabelaComissaoById(Set<String> fields, Set<Id> setId) {
        return Database.query(String.format(
            'SELECT {0} FROM TabelaComissao__c WHERE Id IN :setId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }

    public static List<TabelaComissao__c> getActiveTabelaComissaoByEmpreendimento(Set<Id> empreendimentoIds) {
        return [
            SELECT
                Empreendimento__c
            FROM TabelaComissao__c
            WHERE 
                Ativa__c = true AND
                Empreendimento__c IN :empreendimentoIds 
        ];
    }
}