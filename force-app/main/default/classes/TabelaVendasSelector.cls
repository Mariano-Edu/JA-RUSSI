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
        List<TabelaVendas__c> result = [
            SELECT 
            Id, 
            Name,
            PeriodicidadeParcela__c,
            PercentualParcela__c,
            MesVigencia__c,
            VigenciaInicio__c, 
            TipoVenda__c,
            Empreendimento__c,
            Clonado__c,
            OrigemTabelaDeVenda__c,
            VigenciaFim__c,
            PercentualDeAcrescimo__c 
            FROM TabelaVendas__c 
            WHERE Id = :id 
            LIMIT 1
        ];
        
        return result.isEmpty() ? null : result[0];
    } 

    public static List<SeriePagamentos__c> getSeriesPagamentosPorTabela(Id idTabela) {
        return [
            SELECT 
            Id, 
            Name,
            TabelaVenda__c, 
            TipoCondicao__c,
            InicioPagamento__c,
            QuantidadeParcelas__c,
            ValorTotal__c
            FROM SeriePagamentos__c 
            WHERE TabelaVenda__c = :idTabela
        ];
    }

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
                Empreendimento__r.ValorMetroQuadrado__c	,
                Empreendimento__r.MetragemPrivativaTotal__c,
                DescontoNominalMoeda__c,
                DescontoNominalPorcentagem__c
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
                   TaxaTP__c,
                   MesVigencia__c
            FROM   TabelaVendas__c
            WHERE  Empreendimento__c  = :idEmpreendimento
        ];
    }

    public static List<TabelaVendas__c> obterTabelasVigentesPorIdEmpreendimentoETipoVenda(Id idEmpreendimento, String tipoVenda) {
        return [
            SELECT Id, 
                   Name,
                   Situacao__c,
                   Ativo__c,
                   VigenciaInicio__c,
                   VigenciaFim__c,
                   TaxaDescontoVPL__c,
                   TaxaTP__c,
                   MesVigencia__c
            FROM   TabelaVendas__c
            WHERE  
                Empreendimento__c  = :idEmpreendimento
            AND   
                Situacao__c = 'Em vigor'
            AND
                TipoVenda__c = :tipoVenda
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
}