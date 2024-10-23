public class SeriePagamentosService {
    // Cria as lista nescessarias para o calculo
    private static List<ValorLinha> listaGlobal = new List<ValorLinha>();
    private static List<ValorLinha> listaValoresReais = new List<ValorLinha>();
    private static List<ValorLinha> listaVPL = new List<ValorLinha>();

    //Cria as variaveis com as informações da tabela
    private static String  idTabelaDeVendas;
    private static Decimal taxaPos;
    private static Decimal taxaAte;

    //Valor Nominal da proposta do cliente
    private static Decimal valorTotalPropostaValido;

    //criar mapa para retorno de calculo VPL e Nominal
    public static Map<String, Decimal> retornoValoresReaisVPL = new Map<String,Decimal>();

    //Metodo para retornar os valores calculado da series da proposta do cliente
    public static Map<String, Decimal> setValorRealPropostaCliente(Id idTabelaVendas, List<ObjetoSerie> seriesPropostas, Decimal valorTotalProposta){
        valorTotalPropostaValido = valorTotalProposta;
        limparListas();
        setarHabiteSe(idTabelaVendas);
        inicioPropostaCliente(seriesPropostas);
        Map<String, Decimal> retorno = retornoValoresReaisVPL;
        return retorno;
    }

    public static Map<String, Decimal> setValorRealVPLTabelaVendas(Id idTabelaVendas){
        valorTotalPropostaValido = 0.0;
        limparListas();
        setarHabiteSe(idTabelaVendas);
        Map<Id, SeriePagamentos__c> series = new Map<Id, SeriePagamentos__c> (SeriePagamentoSelector.obterSeriesPorIdTabela(idTabelaVendas));
        inicioSerieTabelaVendas(series);
        Map<String, Decimal> retorno = retornoValoresReaisVPL;
        return retorno;
    }

    //Metodo para setar as infomorções nescessarias da tabela de vendas
    public static void setarHabiteSe (Id tabelaVenda){
        TabelaVendas__c tabelaRelacionada = TabelaVendasSelector.obterTabelasRelacionadas(tabelaVenda);

        //taxaPos = tabelaRelacionada.AntecipacaoAposHabiteSe__c;
        //taxaAte = tabelaRelacionada.AntecipacaoAteHabiteSe__c;
        taxaAte = 0.0;
        idTabelaDeVendas = tabelaRelacionada.Id;
    }

    //Metodo que trata as series inseridas sistema inicia os calculos
    public static void inicioSerieTabelaVendas(Map<Id, SeriePagamentos__c> mapaSeriesPagamento){
        Set<Id> idsNaoEncontrados = mapaSeriesPagamento.keySet();

        System.debug('InicioSerieTabelaVendas');
        if (mapaSeriesPagamento.keySet() == null || mapaSeriesPagamento.keySet().isEmpty()) {
            throw new IllegalArgumentException('Nenhum ID de série de pagamentos fornecido.');
        }
        
        List<SeriePagamentos__c> seriesDePagamentos = mapaSeriesPagamento.values();
        List<ObjetoSerie> seriesDePagamentosDTO = new List<ObjetoSerie>();
        for(SeriePagamentos__c serie : seriesDePagamentos){
            idsNaoEncontrados.remove(serie.Id);
            ObjetoSerie serieDTO = new ObjetoSerie();
            serieDTO.id = serie.Id;
            serieDTO.valorTotal = serie.ValorTotal__c;
            serieDTO.quantidadeParcelas = serie.QuantidadeParcelas__c.intValue();
            serieDTO.periodicidade = serie.Periodicidade__c.intValue();
            serieDTO.inicioPagamento = serie.InicioPagamento__c.intValue();
            serieDTO.tabelaVenda = serie.TabelaVenda__c;
            serieDTO.aposHabiteSe = serie.AposHabiteSe__c;
            serieDTO.restante = serie.Restante__c;
            seriesDePagamentosDTO.add(serieDTO);
        }

        if (!idsNaoEncontrados.isEmpty()) {
            List<String> idsNaoEncontradosStr = new List<String>();
            for (Id id : idsNaoEncontrados) {
                idsNaoEncontradosStr.add(id.toString());
            }
            System.debug('IDs de séries de pagamentos não encontrados: ' + String.join(idsNaoEncontradosStr, ', '));
        }

        calcularSerieDePagamentos(seriesDePagamentosDTO);
    }

    //Metodo que inicia os calculos da series da proposta do cliente
    public static void inicioPropostaCliente(List<ObjetoSerie> seriesPagamentosCliente){
        calcularSerieDePagamentos(seriesPagamentosCliente);
    }
    
    //Metodo que centraliza as chamadas de calculos
    public static void calcularSerieDePagamentos(List<ObjetoSerie> seriesDePagamentos) { 
        System.debug('InicioCalcularSerieDePagamentos');
        
        List<Map<String, Object>> listaSeriesInfo = new List<Map<String, Object>>();

        for (ObjetoSerie serie : seriesDePagamentos) {
            
            if (serie.valorTotal == null || serie.quantidadeParcelas == null || serie.quantidadeParcelas == 0) {
                System.debug('Série de Pagamento ID ' + serie.id + ' possui valor total ou quantidade de parcelas inválidos.');
                continue;
            }
    
            List<Decimal> valoresParcelas = calcularParcelas(serie.valorTotal, serie.quantidadeParcelas);
            
            Map<String, Object> serieInfo = new Map<String, Object>();
            serieInfo.put('serieDePagamentos', serie);
            serieInfo.put('valoresParcelas', valoresParcelas);
            
            listaSeriesInfo.add(serieInfo);
        }
    
        if (!listaSeriesInfo.isEmpty()) {
            criarMatrizCondicoes(listaSeriesInfo);
        }
    }
    
    //Calculo das parcelas
    private static List<Decimal> calcularParcelas(Decimal valorTotal, Integer quantidadeParcelas) {
        List<Decimal> valoresParcelas = new List<Decimal>();
        Decimal valorParcela = valorTotal / quantidadeParcelas;
        for (Integer i = 0; i < quantidadeParcelas; i++) {
            valoresParcelas.add(valorParcela);
        }
        return valoresParcelas;
    }

    //cria a matriz que é utilizado nos calculos de VPL e Valor Nominal
    public static List<ValorLinha> criarMatrizCondicoes(List<Map<String, Object>> listaSeriesInfo) {
        System.debug('InicioCriarMatrizCondicoes');
        List<ValorLinha> listaTemporaria = new List<ValorLinha>();
        
        for (Map<String, Object> serieInfo : listaSeriesInfo) {
            ObjetoSerie serieDePagamentos = (ObjetoSerie) serieInfo.get('serieDePagamentos');
            List<Decimal> valoresParcelas = (List<Decimal>) serieInfo.get('valoresParcelas');
            ObjetoSerie serieHabites = (ObjetoSerie) serieInfo.get('serieDePagamentos');
            Boolean aposHabiteSe = serieHabites.aposHabiteSe;
            Boolean restante = serieHabites.restante;

            Integer mesesParaInicio = serieDePagamentos.inicioPagamento != null ? serieDePagamentos.inicioPagamento : 0;
            Date dataInicio = Date.today().addMonths(mesesParaInicio);
            Integer quantidadeParcelas = serieDePagamentos.quantidadeParcelas != null ? serieDePagamentos.quantidadeParcelas : 0;
            Integer periodicidade = serieDePagamentos.periodicidade != null ? serieDePagamentos.periodicidade : 1;

            for (Integer i = 0; i < quantidadeParcelas; i++) {
                Date dataLinha = dataInicio.addMonths(i * periodicidade);
                ValorLinha novaLinha = new ValorLinha();
                novaLinha.dataLinha = dataLinha;
                novaLinha.valorTotal = 0;

                Boolean encontrouLinha = false;
                for (ValorLinha linha : listaTemporaria) {
                    if (linha.dataLinha == dataLinha) {
                        linha.valorTotal += 0;
                        encontrouLinha = true;
                        break;
                    }
                }

                if (!encontrouLinha) {
                    listaTemporaria.add(novaLinha);
                }
            }

            for (Integer i = 0; i < quantidadeParcelas; i++) {
                Date dataLinha = dataInicio.addMonths(i * periodicidade);
                Decimal valorParcela = valoresParcelas.size() > i ? valoresParcelas[i] : 0;
                Decimal valorTotal = valorParcela;
                
                for (ValorLinha linha : listaTemporaria) {
                    if (linha.dataLinha == dataLinha) {
                        linha.valorTotal += valorParcela;
                        linha.aposHabiteSe = aposHabiteSe;
                        linha.restante = restante;
                        break;
                    }
                }
            }
        }

        List<ValorLinha> listaOrdenada = new List<ValorLinha>();
        
        for (ValorLinha linha : listaTemporaria) {
            Boolean adicionou = false;

            for (Integer j = 0; j < listaOrdenada.size(); j++) {
                if (linha.dataLinha <= listaOrdenada[j].dataLinha) {
                    listaOrdenada.add(j, linha);
                    adicionou = true;
                    break;
                }
            }
            
            if (!adicionou) {
                listaOrdenada.add(linha);
            }
        }

        Integer contadorPosicao = 0;
        for (ValorLinha linha : listaOrdenada) {
            linha.posicao = contadorPosicao++;
        }
        
        listaGlobal = listaOrdenada;
        
        listaValoresReais = criarMatrizValoresReias(idTabelaDeVendas);
        retornoValoresReaisVPL.put('valorNominal', somarValores(listaValoresReais));
        
        listaVPL = criarMatrizVPL(idTabelaDeVendas, listaGlobal); 
        retornoValoresReaisVPL.put('valorVPL', somarValores(listaVPL));
        
        System.debug('Valor nominal: ' + retornoValoresReaisVPL.get('valorNominal'));
        System.debug('Valor VPL: ' + retornoValoresReaisVPL.get('valorVPL'));
        exibirMatrizConsolidada();
        return listaGlobal;
      
    }

    //retorna os valores Nominais
    public static List<ValorLinha> criarMatrizValoresReias(Id tabelaRelacionada) {
        System.debug('InicioCriarMatrizValroesReais');
        List<UnidadeTabelaVendas__c> unidadesTabelaVendas = UnidadeTabelaSelector.obterUnidadeTabelaPorId(tabelaRelacionada);
    
        if (unidadesTabelaVendas.isEmpty()) {
            throw new IllegalArgumentException('Nenhuma unidade de tabela de vendas encontrada.');
        }
    
        UnidadeTabelaVendas__c unidade = unidadesTabelaVendas[0];
        Decimal valorTotalReais = valorTotalPropostaValido != 0.0 ? valorTotalPropostaValido : unidade.PrecoLista__c;

        for (ValorLinha linha : listaGlobal) {
            ValorLinha novaLinhaReais = new ValorLinha();
            novaLinhaReais.posicao = linha.posicao;
            novaLinhaReais.dataLinha = linha.dataLinha;
            novaLinhaReais.valorTotal = linha.valorTotal * (valorTotalReais / 100); 
            novaLinhaReais.aposHabiteSe = linha.aposHabiteSe;
            listaValoresReais.add(novaLinhaReais);
        }
    
        exibirMatrizReaisConsolidada();
        return listaValoresReais;
    }

    //retorna os valores VPL
    public static List<ValorLinha> criarMatrizVPL (Id tabelaRelacionada, List<ValorLinha> listaMatrizGlobla) {
        System.debug('InicioCriarMatrizVPL');
        TabelaVendas__c tabelaVendasRelacionada = TabelaVendasSelector.obterTabelasRelacionadas(tabelaRelacionada);

        if (tabelaVendasRelacionada == null) {
            throw new IllegalArgumentException('Nenhuma tabela de vendas encontrada.');
        }

        for(ValorLinha linha : listaValoresReais) {
            linha.taxaUsada = linha.aposHabiteSe ? taxaPos : taxaAte;

            Decimal valorPresente = linha.valorTotal / (1 + (linha.taxaUsada / 100)).pow(linha.posicao);

            ValorLinha novaLinhaVPL = new ValorLinha();
            novaLinhaVPL.posicao = linha.posicao;
            novaLinhaVPL.dataLinha = linha.dataLinha;
            novaLinhaVPL.valorTotal = valorPresente.setScale(2);
    
            listaVPL.add(novaLinhaVPL);
        }

        exibirMatrizVPLConsolidada();
        return listaVPL;
    }

    //soma os totais 
    public static decimal somarValores(List<ValorLinha> listaLinhas){
        
        Decimal soma = 0;
        for (ValorLinha linha : listaLinhas) {
            soma += linha.valorTotal;
        }

        return soma;
    }

    //limpa as listas globais
    public static List<ValorLinha> limparListas(){
        listaGlobal.clear();
        listaValoresReais.clear();
        listaVPL.clear();
        retornoValoresReaisVPL.clear();

        return listaGlobal;
    }

    public static List<SeriePagamentos__c> seriesProposta(Id idCotacao){
        List<TabelaVendas__c> tabelaRelacionada = TabelaVendasSelector.obterCotacaoRelacionada(idCotacao);
        System.debug('Tabela relacionada a cotação: ' + tabelaRelacionada);

        List<SeriePagamentos__c> seriesProposta = SeriePagamentoSelector.obterSeriesPorIdTabela(tabelaRelacionada[0].Id);
        System.debug('Series de pagamento encontrada: ' + seriesProposta);
        
        return seriesProposta;
    }

    public static void exibirMatrizConsolidada() {
        System.debug('Exibição linha a linha da matriz consolidada (%)');
        for (ValorLinha listaVPL : listaGlobal) {
            System.debug(
                'Data: ' + listaVPL.dataLinha + ' | '
                + 'Posição: ' + listaVPL.posicao  + ' | ' 
                + 'ValorTotal: ' + listaVPL.valorTotal 
            );
        }
    }

    public static void exibirMatrizReaisConsolidada() {
        System.debug('Exibição linha a linha da matriz consolidada Reais (R$)');
        for (ValorLinha linha : listaValoresReais) {
            System.debug(
                'Data: ' + linha.dataLinha + ' | '
                + 'Posição: ' + linha.posicao  + ' | ' 
                + 'ValorTotal: ' + linha.valorTotal 
            );
        }
    }

    public static void exibirMatrizVPLConsolidada() {
        System.debug('Exibição linha a linha da matriz consolidada VPL (R$)');
        for (ValorLinha linha : listaVPL) {
            System.debug(
                'Data: ' + linha.dataLinha + ' | '
                + 'Posição: ' + linha.posicao  + ' | ' 
                + 'ValorTotal VPL: ' + linha.valorTotal
            );
        }
    }

    //DTO utilizado para calcular as linhas
    public class ValorLinha{
        public Integer posicao {get; set;}
        public Date dataLinha {get; set;}
        public Decimal valorTotal {get; set;}
        public Decimal descontoComissao {get; set;}
        public Decimal valorLiquido {get; set;}
        public Decimal taxaUsada {get; set;}
        public Boolean aposHabiteSe {get; set;}
        public Boolean restante {get; set;}
    }

    //DTO utilazdo para transpor Series de pagamentos (SeriePagamentos__c)
    public class ObjetoSerie{
        @AuraEnabled
        public String  id {get; set;}
        @AuraEnabled
        public String  nome {get; set;}
        @AuraEnabled
        public Decimal valorTotal {get; set;}
        @AuraEnabled
        public Integer quantidadeParcelas {get; set;}
        @AuraEnabled
        public Integer periodicidade {get; set;}
        @AuraEnabled
        public integer inicioPagamento {get; set;}
        @AuraEnabled
        public String  tabelaVenda {get; set;}
        @AuraEnabled
        public Boolean aposHabiteSe {get; set;}
        @AuraEnabled
        public boolean restante {get; set;}
    }

}