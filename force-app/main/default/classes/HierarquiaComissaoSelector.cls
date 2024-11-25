public class HierarquiaComissaoSelector {
    public static List<HierarquiaComissao__c> getHierarquiasByTabelaComissao(Id idTabela) {
        return [
            SELECT
                Id,
                Cargo__c,
                ValorComissao__c,
                PercentualComissao__c,
                ValorPremio__c
            FROM HierarquiaComissao__c
            WHERE TabelaComissao__c = :idTabela
        ];
    }
}