public class ComparativoService {
    
    public class ComparacaoResultado {
        @AuraEnabled
        public String item { get; set; } 
        @AuraEnabled
        public Double valorTabela { get; set; }
        @AuraEnabled
        public Double valorProposta { get; set; }
        @AuraEnabled
        public Double diferenca { get; set; }
    }

    public static List<ComparacaoResultado> calcularComparacao(Id unidadeId, Id tabelaId, List<SeriePagamentos__c> proposta) {
        TabelaVendas__c tabelaVenda = TabelaVendasSelector.obterTabelasRelacionadas(tabelaId);

        UnidadeTabelaVendas__c unidadeTabela = UnidadeTabelaSelector.obterEntradaPrecoPorId(unidadeId);
        Decimal valorProposta = 0.0;
        for (SeriePagamentos__c serie : proposta) {
            valorProposta += serie.ValorTotalNominal__c;
        }   
        
        List<UnidadeTabelaVendas__c> tabelaVendaUnidades = TabelaVendasSelector.obterUnidadeTabelasPorId(tabelaId);
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();

        ComparacaoResultado valorM2 = new ComparacaoResultado();
        valorM2.item = 'Valor do m²';
        valorM2.valorTabela = unidadeTabela.ValorMetroQuadradoTabela__c;
        valorM2.valorProposta = valorProposta / unidadeTabela.MetragemUnidade__c;
        valorM2.diferenca =  valorM2.valorProposta - valorM2.valorTabela;
        resultados.add(valorM2);
        
        ComparacaoResultado descontoNominal = new ComparacaoResultado();
        descontoNominal.item = 'Desconto Nominal';
        descontoNominal.valorTabela = unidadeTabela.ValorVenda__c - unidadeTabela.ValorMinimoVenda__c;
        descontoNominal.valorProposta = unidadeTabela.ValorVenda__c - valorProposta;
        descontoNominal.diferenca =  descontoNominal.valorProposta - descontoNominal.valorTabela;
        resultados.add(descontoNominal);
        
        ComparacaoResultado descontoPercentual = new ComparacaoResultado();
        descontoPercentual.item = 'Desconto Percentual';
        descontoPercentual.valorTabela = descontoNominal.valorTabela * 100 / unidadeTabela.ValorVenda__c; 
        descontoPercentual.valorProposta = descontoNominal.valorProposta * 100 / valorProposta;
        descontoPercentual.diferenca = descontoPercentual.valorProposta - descontoPercentual.valorTabela ;
        resultados.add(descontoPercentual);

        return resultados;
    }
}