public with sharing class TabelaVendasSelector {
    public static TabelaVendas__c buscarTabelaPorIdCotacao(Id idCotacao){
        List<TabelaVendas__c> result = [
            SELECT Id 
            FROM TabelaVendas__c 
            WHERE Cotacao__c = :idCotacao 
            LIMIT 1
        ];
        
        return result.isEmpty() ? null : result[0];
    }

    public static TabelaVendas__c getTabelaVendasPorId(Id id) {
        return [
            SELECT 
            Id, 
            Name,
            VigenciaInicio__c, 
            VigenciaFim__c,
            PercentualDeAcrescimo__c 
            FROM TabelaVendas__c 
            WHERE Id = :id 
            LIMIT 1
        ];
    } 
}