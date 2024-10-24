public class UnidadeTabelaSelector {
    public static List<UnidadeTabelaVendas__c> obterUnidadeTabelaPorId(Id tabelaVendaRelacionada){
        return [
            SELECT
            Id,
            TabelaVenda__c,
            PrecoLista__c
            FROM UnidadeTabelaVendas__c 
            WHERE TabelaVenda__c = :tabelaVendaRelacionada
        ];
    }

    public static Map<Id, UnidadeTabelaVendas__c> obterUnidadesTabelaExistentes(set<Id> tabelavendasIds){
        Map<Id,UnidadeTabelaVendas__c> unidadesTabelaMap = new Map<Id, UnidadeTabelaVendas__c>([
            SELECT Id, Name, PrecoLista__c, CoeficienteTabela__c, MetragemUnidade__c, Unidade__c, TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :tabelaVendasIds
        ]);
        return unidadesTabelaMap;
    }

    public static UnidadeTabelaVendas__c obterUnidadesTabelaPorIdUnidade(Id idUnidade){
        return [SELECT id, ValorVenda__c, Unidade__c from UnidadeTabelaVendas__c where Unidade__c =: idUnidade limit 1];
    }
}