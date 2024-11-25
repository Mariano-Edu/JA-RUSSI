public class TabelaVendaSelector {
    public static List<UnidadeTabelaVendas__c> obterUnidadeTabelasPorId (Id tabelaVendasId) {
        return [
            SELECT PrecoLista__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c = :tabelaVendasId
            LIMIT 1
        ];
    }

    public static TabelaVendas__c obterTabelasRelacionadas(Id tabelaRelacionada){
        return [
            SELECT
                Id,
                // Empreendimento__r.ValorM__c,
                Empreendimento__r.MetragemPrivativaTotal__c
            FROM TabelaVendas__c
            WHERE Id = :tabelaRelacionada LIMIT 1
        ];
    }

    public static List<TabelaVendas__c> obterTabelasPorIdEmpreendimento(Id idEmpreendimento) {
        return [
            SELECT Id, 
                   Name,
                   Situacao__c,
                   Ativo__c,
                   VigenciaInicio__c,
                   VigenciaFim__c,
                   TaxaDescontoVPL__c,
                   Empreendimento__r.VagasUnidade__c,
                   TaxaTP__c
            FROM   TabelaVendas__c
            WHERE  Empreendimento__c  = :idEmpreendimento
        ];
    }

    public static List<TabelaVendas__c> obterCotacaoRelacionada(Id idCotacao){
        system.debug('id cotacao no selector' + idCotacao);
        return [
            SELECT
                Id,
                Cotacao__c
            FROM TabelaVendas__c
            WHERE Cotacao__c = :idCotacao
            ORDER BY Cotacao__c DESC
            LIMIT 1
        ];
    }

    public static TabelaVendas__c buscarTabelaPorIdCotacao(Id idCotacao){
        List<TabelaVendas__c> result = [
            SELECT Id 
            FROM TabelaVendas__c 
            WHERE Cotacao__c = :idCotacao 
            LIMIT 1
        ];
        
        return result.isEmpty() ? null : result[0];
    }

    public static TabelaVendas__c  obterCamposParaCloneTabela( Id idTabelaVenda){
        System.debug('id tabela venda no selector' + idTabelaVenda);

        return [
        SELECT Id,
        Name, 
        VigenciaInicio__c, 
        VigenciaFim__c,
        PercentualDeAcrescimo__c 
        FROM TabelaVendas__c 
        WHERE Id = :idTabelaVenda 
        LIMIT 1
        ];
    }
    
}