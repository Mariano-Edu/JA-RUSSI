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

    public static List<ComparacaoResultado> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta) {
        System.debug(proposta);
        TabelaVendas__c tabelaVenda = TabelaVendaSelector.obterTabelasRelacionadas(tabelaId);
        Decimal valorProposta = proposta[0].ValorTotal__c;
        System.debug(valorProposta);
        
        List<UnidadeTabelaVendas__c> tabelaVendaUnidades = TabelaVendaSelector.obterUnidadeTabelasPorId(tabelaId);
        System.debug(tabelaVendaUnidades);
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();


        // 1. Valor do m²
        ComparacaoResultado valorM2 = new ComparacaoResultado();
        valorM2.item = 'Valor do m²';

        // Null check
        valorM2.valorTabela = (tabelaVenda != null && tabelaVenda.Empreendimento__r != null && tabelaVenda.Empreendimento__r.ValorM__c != null) 
                      ? tabelaVenda.Empreendimento__r.ValorM__c 
                      : 0.0;
                      System.debug('Valor m2 tabela'+valorM2.valorTabela);
        
        valorM2.valorProposta = valorProposta/tabelaVenda.Empreendimento__r.MetragemPrivativaTotal__c;
        System.debug('Valor m2 proposta'+valorM2.valorProposta);
        System.debug('Valor Proposta'+ valorM2.valorProposta);
        valorM2.diferenca = valorM2.valorTabela - valorM2.valorProposta;
        System.debug('Valor Diferenca'+valorM2.diferenca);
        resultados.add(valorM2);
       
        System.debug('Resultados'+resultados);
        

        // 2. Valor do m² à vista
        ComparacaoResultado valorM2Vista = new ComparacaoResultado();
        valorM2Vista.item = 'Valor do m² à vista';
        valorM2Vista.valorTabela = 0.0; // Substitua com o campo correto
        valorM2Vista.valorProposta = 0.0; // Substitua com o campo correto
        valorM2Vista.diferenca = valorM2Vista.valorTabela - valorM2Vista.valorProposta;
        resultados.add(valorM2Vista);

        // Captação até metado do prazo da obra
        ComparacaoResultado captacaoObra= new ComparacaoResultado();
        captacaoObra.item = 'Captação até metade do prazo da obra';
        captacaoObra.valorTabela = 0.0; // Substitua com o campo correto
        captacaoObra.valorProposta = 0.0; // Substitua com o campo correto
        captacaoObra.diferenca = captacaoObra.valorTabela - captacaoObra.valorProposta;
        resultados.add(captacaoObra);

        // 4.Captação até habite-se
        ComparacaoResultado captacaoAteHabiteSe = new ComparacaoResultado();
        captacaoAteHabiteSe.item = '% de Captação até habite-se';
        captacaoAteHabiteSe.valorTabela = 0.0; // Substitua com o campo correto
        captacaoAteHabiteSe.valorProposta = 0.0; // Substitua com o campo correto
        captacaoAteHabiteSe.diferenca = captacaoAteHabiteSe.valorTabela - captacaoAteHabiteSe.valorProposta;
        resultados.add(captacaoAteHabiteSe);

        // Captação após habita-se
        ComparacaoResultado captacaoAposHabiteSe  = new ComparacaoResultado();
        captacaoAposHabiteSe.item = 'Captação apos habite-se';
        captacaoAposHabiteSe.valorTabela = 0.0; // Substitua com o campo correto
        captacaoAposHabiteSe.valorProposta = 0.0; // Substitua com o campo correto
        captacaoAposHabiteSe.diferenca = captacaoAposHabiteSe.valorTabela - captacaoAposHabiteSe.valorProposta;
        resultados.add(captacaoAposHabiteSe);

        // Desconto nominal
        ComparacaoResultado descontoNominal = new ComparacaoResultado();
        descontoNominal.item = 'Desconto Nominal';
        descontoNominal.valorTabela = 0.0;  // Substitua com o campo correto
        descontoNominal.valorProposta =0.0; // Substitua com o campo correto
        descontoNominal.diferenca = descontoNominal.valorTabela - descontoNominal.valorProposta;
        resultados.add(descontoNominal);


        return resultados;
    }
}