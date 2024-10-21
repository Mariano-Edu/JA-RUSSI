public class ExtratoTabelaService {

    public class ComparacaoResultado {
        @auraEnabled
        public String criterio { get; set; }
        @auraEnabled
        public Decimal valorTabela {get; set;} 
        @auraEnabled
        public Decimal valorProposta {get; set;} 
        @auraEnabled
        public Boolean dentroDoLimite {get; set;}
        @auraEnabled
        public String aprovado {get; set;}
    }

    // Método auxiliar para criar ComparacaoResultado com formatação
    private static ComparacaoResultado criarComparacao(String criterio, Decimal valorTabela, Decimal valorProposta) {
        ComparacaoResultado resultado = new ComparacaoResultado();
        resultado.criterio = criterio;
        resultado.valorTabela = valorTabela.setScale(2);  // Formatação com 2 casas decimais
        resultado.valorProposta = valorProposta.setScale(2);  // Formatação com 2 casas decimais
        resultado.dentroDoLimite = valorProposta <= valorTabela;
        resultado.aprovado = resultado.dentroDoLimite ? 'utility:success' : 'utility:error';
        return resultado;
    }

    // realisa a analise entre valores da tabela de venda e da proposta do cliente
    public static List<Object> analisarProposta(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz) {
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();
        List<SeriePagamentos__c> series = SeriePagamentoSelector.obterSeriePagamentosPorInicioPagamento(tabelaId);

        Decimal quantidadeParcelas = 0.0;
        Decimal quantidadeParcelasProp = 0.0;
        Decimal captacaoVistaTabela = 0.0;
        Decimal captacaoVistaProposta = 0.0;
        Decimal captacaoMensalTabela = 0.0;
        Decimal captacaoMensalProposta = 0.0;
        Decimal captacaoAteHabTabela = 0.0;
        Decimal captacaoAteHabProposta = 0.0;

        // Processando todas as séries em uma única iteração
        for (SeriePagamentos__c s : series) {
            quantidadeParcelas += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;

            if (s.TipoCondicao__c == 'Ato') {
                captacaoVistaTabela = s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (s.TipoCondicao__c == 'Mensais') {
                captacaoMensalTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (!s.AposHabiteSe__c) {
                captacaoAteHabTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
        }

        for (SeriePagamentos__c s : proposta) {
            quantidadeParcelasProp += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;

            if (s.TipoCondicao__c == 'Ato') {
                captacaoVistaProposta = (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
            if (s.TipoCondicao__c == 'Mensais') {
                captacaoMensalProposta += (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
            if (!s.AposHabiteSe__c) {
                captacaoAteHabProposta += (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
        }

        TabelaVendas__c tabela = TabelaVendaSelector.obterTabelasRelacionadas(tabelaId);

        if (valoresMatriz != null) {
            resultados.add(criarComparacao('Valor nominal', (Decimal) valoresMatriz.get('nominalTabela'), (Decimal) valoresMatriz.get('nominalProposta')));
            resultados.add(criarComparacao('Valor VPL', (Decimal) valoresMatriz.get('valorVplTabela'), (Decimal) valoresMatriz.get('valorVplProposta')));
        } else {
            System.debug('valoresMatriz é null');
        }

        resultados.add(criarComparacao('Prazo de financiamento', quantidadeParcelas, quantidadeParcelasProp));
        resultados.add(criarComparacao('% de Captação à vista', captacaoVistaTabela, captacaoVistaProposta));
        resultados.add(criarComparacao('% de Captação até habita-se', captacaoAteHabTabela, captacaoAteHabProposta));
        resultados.add(criarComparacao('% de Captação mensal', captacaoMensalTabela, captacaoMensalProposta));
        
        return resultados;
    }
}