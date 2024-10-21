public class SeriePagamentoSelector {
    public static List<SeriePagamentos__c> obterSeriePagamentosPorInicioPagamento(Id tabelaVendasId){
        return  [ 
            SELECT
                TipoCondicao__c,
                InicioPagamento__c,
                ValorTotal__c,
                QuantidadeParcelas__c,
                Periodicidade__c,
                AposHabiteSe__c,
                Restante__c
            FROM SeriePagamentos__c
            WHERE TabelaVenda__c = :tabelaVendasId
            ORDER By InicioPagamento__c ASC
        ];
    }

    public static List<SeriePagamentos__c> obterSeriePorId(Id serieDePagamentosId){
        return [
            SELECT 
                Id,
                TipoCondicao__c,
                ValorTotal__c,
                QuantidadeParcelas__c, 
                InicioPagamento__c,
                Periodicidade__c,
                Restante__c,
                AposHabiteSe__c,
                TabelaVenda__c
            FROM SeriePagamentos__c 
            WHERE Id = :serieDePagamentosId
            LIMIT 1
        ];
    }

    public static list<SeriePagamentos__c> obterSeriePorIdTabelaVendas (Id tabelaPagamentoId){
        return [
            SELECT
                id,
                TipoCondicao__c,
                InicioPagamento__c,
                QuantidadeParcelas__c,
                ValorTotal__c,
                AposHabiteSe__c 
            FROM SeriePagamentos__c
            WHERE TabelaVenda__c = :tabelaPagamentoId
        ];
    }

    public static List<SeriePagamentos__c> obterSeriesPorIdTabela(Id idTabelaVendas){
        return [
            SELECT 
                Id,
                ValorTotal__c,
                QuantidadeParcelas__c,
                Periodicidade__c,
                InicioPagamento__c,
                TabelaVenda__c,
                AposHabiteSe__c,
                Restante__c,
                TipoCondicao__c
            FROM SeriePagamentos__c
            WHERE TabelaVenda__c = :idTabelaVendas
        ];
    }

    public static List<SeriePagamentos__c> obterSeriesPeloRestante(Set<Id> idTabelaVendas){
        return [
            SELECT
                Id,
                TabelaVenda__c 
            FROM SeriePagamentos__c 
            WHERE TabelaVenda__c 
            IN :idTabelaVendas
            AND Restante__c = true
        ];
    }
}