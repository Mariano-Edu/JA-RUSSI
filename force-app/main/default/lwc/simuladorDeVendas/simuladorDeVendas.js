import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import obterOportunidadePorIdCotacao from '@salesforce/apex/OpportunityController.obterOportunidadePorIdCotacao';
import concluirSimulacao from '@salesforce/apex/CotacaoController.concluirSimulacao';
import buscarSeriesPorCotacao from '@salesforce/apex/CotacaoController.buscarSeriesPorCotacao';
import obterEntradaPrecoPorUnidade from '@salesforce/apex/CotacaoController.obterEntradaPrecoPorUnidade';

import { NavigationMixin } from 'lightning/navigation';
import obterTabelasVigentesPorIdEmpreendimentoETipoVenda from '@salesforce/apex/SimuladorTelaNegociacaoController.obterTabelasVigentesPorIdEmpreendimentoETipoVenda';

const tabelaVendasColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c', type: 'number' },
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c', type: 'number' },
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency' },
    { label: 'Valor Total', fieldName: 'ValorTotal', type: 'currency' },
    { label: '% Parcela', fieldName: 'porcentagemParcela', type: 'number' },
    { label: '% Total', fieldName: 'ValorTotal__c', type: 'number' }
];

const periodicidades = [
        {tipoCondicao: 'Ato', periodicidade: 1}, 
        {tipoCondicao: 'Mensais', periodicidade: 1}, 
        {tipoCondicao: 'Sinal', periodicidade: 1}, 
        {tipoCondicao: 'Única', periodicidade: 1}, 
        {tipoCondicao: 'Financiamento', periodicidade: 1}, 
        {tipoCondicao: 'Periódica', periodicidade: 1}, 
        {tipoCondicao: 'Bimestral', periodicidade: 2}, 
        {tipoCondicao: 'Trimestral', periodicidade: 3}, 
        {tipoCondicao: 'Semestrais', periodicidade: 6}, 
        {tipoCondicao: 'Anuais', periodicidade: 12}
    ];

export default class SimuladorDeVendas extends NavigationMixin(LightningElement) {
    
    tabelaVendasColunas = tabelaVendasColunas;
    periodicidades = periodicidades;

    @track currentStep = 0;
    
    @track produtoSelecionado;
    @track idProdutoSelecionado;

    @track tabelaVendasVingenteValue;

    @track ultimaTabelaSelecionada;
    @track tabelaVendaSelecionada;
    @track tabelaVendasInfoComplementares; 
    @track seriesVendaTabelaSelecionada;

    @track valorNominalTabelaSelecionada = 0;
    @track valorVplTabelaSelecionada = 0;

    @track propostasCliente = [];
    @track valorNominalProposta = 0;
    @track valorVplProposta = 0;

    
    @track cotacaoRecord;
    propostaTravada = false;

    @track opportunity;

    @track empreendimentoSelecionado;

    @track qtdVagasSelecionadas;
    @track vagasExtras;
    @track vagasSelecionadasInfo = [];
    @track valorVaga;

    @track simulacaoFinalizada;
    @track propostasCotacao;

    @track descontoNominal;
    @track descontoPercentual;
    @track isParaAprovacao;

    @api tabelaSelecionada;

    @api tabelaOptions;
    @api tabelasVendas;
    @api entradaPrecosMap;
    @api recordId;

    @api tabelasVendaSelecionada;

    @api unidadeSelecionada;
    @api entradaPrecoSelecionada;
    @api tabelaMesVigencia;


    get getDescontoNominal() {
        return this.descontoNominal;
    }

    get getDescontoPercentual() {
        return this.descontoPercentual;
    }

    get getTabelaOptions() {
        return this.tabelaOptions;
    }

    get getTabelasVendas() {
        return this.tabelasVendas;
    }

    get getTabelaMesVigencia() {
        return this.tabelasVendas;
    }

    get getEntradaPrecosMap() {
        return this.entradaPrecosMap;
    }

    get getEntradaPrecoSelecionada() {
        return this.entradaPrecoSelecionada;
    }

    get getEmpreendimentoSelecionado() {
        return this.empreendimentoSelecionado;
    }

    get getUrlConta() {
        return `/lightning/r/Account/${this.opportunity.Account.Id}/view`;
    }

    get getUrlProprietario() {
        return `/lightning/r/User/${this.opportunity.Owner.Id}/view`;
    }

    get isSimulacaoFinalizada() {
        return this.cotacaoRecord?.fields.Status.value !== 'Negociação';
    }

    get getPropostasCotacao() {

        return this.propostasCotacao;
    }

    get getUnidadeSelecionada() {
        return this.unidadeSelecionada;
    }

    get currentStepValue() {
        return this.stepValues[this.currentStep];
    }

    get etapaEspelho() {
        return this.currentStepValue === 'espelho';
    }

    get etapaVagas() {
        return this.currentStepValue === 'vagas';
    }

    get etapaRevisao() {
        return this.currentStepValue === 'revisao';
    }
    
    get etapaNegociacao() {
        return this.currentStepValue === 'negociacao';
    }

    get isFirstStep() {
        return this.currentStep === 0;
    }

    get isLastStep() {
        return this.currentStep === 4;
    }

    get getProdutoSelecionado(){
        return {
            'idUnidade': this.produtoSelecionado.Id,
            'idEmpreendimento': this.produtoSelecionado.Empreendimento__c,
            'DiasDeVencimentoDaParcela': this.produtoSelecionado.diasVencimento ? this.produtoSelecionado.diasVencimento : ""
        };
    }
    
    get getIdEmpreendimento(){
        return this.produtoSelecionado.empreendimentoId;
    }

    get getTabelaSelecionada(){
        return this.tabelaSelecionada;
    }

    get getTabelaMesVigencia(){
        return this.tabelaMesVigencia;
    }

    get getValorNominalProposta(){
        return this.valorNominalProposta;
    }

    get getValorVplProposta(){
        return this.valorVplProposta;
    }

    
    get getValoresMatriz(){
        return {
            nominalProposta: this.valorNominalProposta,
            valorVplProposta: this.valorVplProposta, 
            nominalTabela: this.entradaPrecoSelecionada?.ValorVenda__c,
            valorVplTabela: this.valorVplTabelaSelecionada,
            entradaPrecoSelecionada: this.entradaPrecoSelecionada
        }
    }

    get getCotacaoName(){
        return this.cotacaoRecord.fields.Name.value
    }

    get getCotacaoId(){
        return this.recordId;
    }

    get isAnalisarBloqueado() {
        
        for (let i = 0; i < this.propostasCliente?.length; i++) {
            let campos = Object.keys(this.propostasCliente[i]);
            for (let j = 0; j < campos?.length; j++) {
                if (this.propostasCliente[i][campos[j]] === null) return true;
            }
        }

        return !(this.propostasCliente?.length > 0);
    }

    @wire(obterOportunidadePorIdCotacao, { idCotacao: '$recordId' })
    wiredOpportunity({ error, data }) {
        
        if (data) {
            this.opportunity = data;
            this.buscarTabelas();
            
        } else if (error) {
            console.error('Erro ao carregar oportunidade:', error);
        }
    }

    stepValues = [
        'espelho', 'vagas', 'revisao', 'negociacao', 'extrato'
    ];

    handleVagasChange(event) {
        this.qtdVagasSelecionadas = event.detail.qtdVagasSelecionadas;
        this.vagasExtras = event.detail.vagasExtras;
        const vagas = event.detail.vaga;
        
        vagas.forEach(vaga => {
            const exists = this.vagasSelecionadasInfo.some(existingVaga => existingVaga.id === vaga.id);
    
            if (!exists) {
                this.vagasSelecionadasInfo.push(vaga);
            } else {
                this.vagasSelecionadasInfo = this.vagasSelecionadasInfo.map(existingVaga => 
                    existingVaga.id === vaga.id ? { ...existingVaga, ...vaga } : existingVaga
                );
            }
        });
    }

    wiredQuoteResult;
    @wire(getRecord, { recordId: '$recordId', fields: ['Quote.Name', 'Quote.Status'] })
    wiredQuote(result) {
        this.wiredQuoteResult = result;
        const { error, data } = result;

        if (data) {
            this.cotacaoRecord = data;
        } else if (error) {
            console.error(error);
            this.cotacaoRecord = undefined;
        }
    }

    wiredQuoteSeriesResult;
    @wire(buscarSeriesPorCotacao, { idCotacao: '$recordId' })
    wiredQuoteSeries(result) {
        this.wiredQuoteSeriesResult = result;
        const { error, data } = result;

        if (data) {
            
            let valorNominalProposta = 0;

            this.propostasCotacao = data.map(serie => {
                valorNominalProposta += parseFloat(serie.ValorTotalNominal__c || 0);

                return {
                    ...serie,
                    vencimentoParcela: `Dia ${serie.DiaVencimentoParcela__c || 'não definido'}`,
                    valorTotal: serie.ValorTotalNominal__c,
                    valorParcela: serie.QuantidadeParcelas__c ? 
                        serie.ValorTotalNominal__c / serie.QuantidadeParcelas__c : 0
                };
            });

            this.valorNominalProposta = parseFloat(valorNominalProposta);

            this.propostasCotacao = this.propostasCotacao.map(serie => {
                const porcValorTotal = this.valorNominalProposta ? 
                    (serie.ValorTotalNominal__c / this.valorNominalProposta) * 100 : 0;
                
                const porcParcela = serie.QuantidadeParcelas__c ? 
                    porcValorTotal / serie.QuantidadeParcelas__c : 0;

                return {
                    ...serie,
                    ValorTotal__c: `${porcValorTotal.toFixed(2)}%`,
                    porcentagemParcela: `${porcParcela.toFixed(2)}%`
                };
            });
            

        } else if (error) {
            console.error(error);
            this.propostasCotacao = undefined;
        }
    }

    refreshQuoteData() {
        refreshApex(this.wiredQuoteResult);
        refreshApex(this.wiredQuoteSeriesResult);
    }

    buscarTabelas() {
        if (!this.opportunity) {
            this.tabelaOptions = [];
            this.tabelaVendas = [];
            return;
        }
        this.opportunityTipoVenda = this.opportunity.TipoVenda__c;
        this.empreendimentoSelecionado = this.opportunity.EmpreendimentodeInteresse__c;
        
        obterTabelasVigentesPorIdEmpreendimentoETipoVenda({ idEmpreendimento: this.empreendimentoSelecionado, tipoVenda: this.opportunityTipoVenda })
            .then(data => {
                this.tabelasVendas = data;
                this.tabelaMesVigencia = data[0].MesVigencia__c;

                this.tabelaOptions = data.map(tabela => ({
                    label: tabela.Name,
                    value: tabela.Id
                }));
            })
            .catch(error => {
                console.error('Erro ao obter tabelas vigentes:', error)
                this.tabelaOptions = [];
                this.tabelaVendas = [];
            });
    }

    @wire(obterEntradaPrecoPorUnidade, {
        idTabela: '$tabelaSelecionada',
    })
    wiredEntradaPrecos({ error, data }) {
        if (data) {
            this.entradaPrecosMap = data;
        } else if (error) {
            console.error('Erro ao buscar produtos:', error);
        }
    }

    doPrevStep() {

        if(this.isFirstStep) return;

        switch (this.currentStep){
            case 0:
                this.currentStep--;
            case 1:
                this.limparDadosSimulacao();

                this.currentStep--;
            break;
            case 2:
                this.vagasSelecionadasInfo = [];
                this.currentStep--;
            break;
            case 3:
                this.currentStep--;
            break;
            case 4:
                this.propostaTravada = true;
                this.currentStep--;
            break;

        }
    }

    showNotification(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
          title: titulo,
          message: mensagem,
          variant: variante,
        });
        this.dispatchEvent(evt);
      }

    
    doNextstep() {
        
        if(this.isLastStep) return;

        switch (this.currentStep){
            case 0:

            if (!this.produtoSelecionado) {
                this.showNotification("Unidade não selecionada", "Selecione uma unidade para prosseguir", "error")
                return;
            }

            if (this.produtoSelecionado.status !== 'Disponível') {
                this.showNotification("Unidade deve estar disponível", "Selecione uma unidade disponível para prosseguir", "error")
                return;
            }
            
                this.currentStep++;
            break;

            case 1:
                this.currentStep++
            break;

            case 2:
                this.currentStep++;
            break;

            case 3:                
                this.currentStep++;
            break;
            
            case 4:
                this.currentStep++;
            break;

        }
        
    }

    handleChooseUnidade(event) {
        let produtoSelecionado = event.detail.produtoSelecionado;
        this.produtoSelecionado = {...produtoSelecionado}
        this.entradaPrecoSelecionada = this.entradaPrecosMap[this.produtoSelecionado.id];
    }

    handleSelecionarTabela(event) {
        this.tabelaSelecionada = event.detail.idTabela;
        this.tabelaOptions = event.detail.tabelaOptions;
    }

    handleSelecionarSerie(event) {
        this.seriesPagamentos = event.detail;
    }

     buscarTabelaVingente(){
        let idTabelaVendasVingente;

        this.tabelasVendas.forEach(tabela=>{
            if(tabela.Situacao__c == 'Em vigor' && tabela.Ativa__c){
                idTabelaVendasVingente = tabela.Id;
            }
        })

        if (!idTabelaVendasVingente){return;}
        return this.tabelasVendas.find(tabela => tabela.Id === idTabelaVendasVingente);
    }

    adicionarNovaCondicao(){
        const novaCondicao = {
            uid: this.generateUniqueId(),
            TipoCondicao__c: null,
            InicioPagamento__c: null,
            vencimentoParcela: null,
            QuantidadeParcelas__c: null,
            valorParcela: null,
            valorTotal: null,
            porcentagemParcela: null,
            ValorTotal__c: null,
        };
        let propostasClienteClone = [...this.propostasCliente];
        propostasClienteClone.push(novaCondicao);
        this.propostasCliente = propostasClienteClone;

    }
    
    changeSeriesProposta(event){
        let seriesTabelaDeVenda = event.detail;
        this.propostasCliente = seriesTabelaDeVenda;
        
        this.calcularFinanceiroProposta();
    }

    deletarCondicao(event){
        let serieProposta = this.propostasCliente.find(serie => serie.uid === event.detail.uid);

        let updatedPropostasCliente = this.propostasCliente.filter(item => item.uid !== serieProposta.uid);

        this.propostasCliente = updatedPropostasCliente;
        
        this.calcularFinanceiroProposta();

        this.showNotification("Serie do tipo: " + serieProposta.TipoCondicao__c + " deletada com sucesso!" , "Novo valor nominal da proposta: " + this.formatCurrency(this.valorNominalProposta), "success");
    }

    handleZerarCondicao(event){
        let diferencaNominalTabelaProposta = Math.abs(this.valorNominalProposta - this.entradaPrecosMap[this.produtoSelecionado.id]?.ValorVenda__c);
        
        if(diferencaNominalTabelaProposta === 0){
            this.showNotification("Não há diferença para ser subtraida!", "", "info");
            return;
        }

        let serieProposta = this.propostasCliente.find(serie => serie.uid === event.detail.uid);
        
        let valorSubtrairDoValorTotalProposta;
        let valorTotalPropostaRecalculado;
        let diferencaValorTotalValorTotalRecalculado;
        let valorSubtrairDoValorParcela;

        valorSubtrairDoValorParcela = diferencaNominalTabelaProposta / serieProposta.QuantidadeParcelas__c;
        valorTotalPropostaRecalculado = Math.abs((serieProposta.valorParcela - valorSubtrairDoValorParcela) * serieProposta.QuantidadeParcelas__c);
        diferencaValorTotalValorTotalRecalculado = serieProposta.valorTotal - valorTotalPropostaRecalculado;
        valorSubtrairDoValorTotalProposta = Math.abs(diferencaValorTotalValorTotalRecalculado - diferencaNominalTabelaProposta);
        serieProposta.valorTotal = Math.abs(serieProposta.valorTotal - valorSubtrairDoValorTotalProposta);

        this.showNotification("Valor total da parcela descontado", "Valor descontado:  " + this.formatCurrency(valorSubtrairDoValorTotalProposta), "success");

        this.calcularFinanceiroProposta();
    }


    editarCondicao(event){
   
        const uid = event.detail.uid;
        const fieldName = event.detail.name;
        const fieldType = event.detail.type

        let newValue;
        let serieProposta = this.propostasCliente.find(serie => serie.uid === uid);
    
        if (fieldType === 'toggle') { 
            newValue = event.detail.checked;
        } else {
            newValue = event.detail.value;
        }

        serieProposta[fieldName] = newValue;
        
        if(fieldName != 'QuantidadeParcelas__c' && fieldName != 'valorParcela' && fieldName != 'valorTotal'){return;}

        switch(fieldName){
            case 'valorParcela':
                this.calcularValorTotalPropostaSerie(serieProposta);
            break;
            case 'valorTotal':
                this.calcularValorParcelaPropostaSerie(serieProposta);
            break;
            case 'QuantidadeParcelas__c':
                if(serieProposta.valorTotal === null){
                    this.calcularValorTotalPropostaSerie(serieProposta);
                    return;
                }

                if(serieProposta.valorParcela === null){
                    this.calcularValorParcelaPropostaSerie(serieProposta);
                    return;
                }

                this.calcularValorParcelaPropostaSerie(serieProposta);
            break;
        }

        this.calcularFinanceiroProposta();
    }

    calcularDesconto() {
        this.descontoNominal = parseFloat(this.entradaPrecoSelecionada.ValorVenda__c) - parseFloat(this.valorNominalProposta);
        this.descontoPercentual = 100 * this.descontoNominal / this.entradaPrecoSelecionada.ValorVenda__c;
    }

    setTabelaSelecionada(event){
        
    }

    calcularValorTotalPropostaSerie(propostaSerie){
        const {QuantidadeParcelas__c, valorParcela } = propostaSerie;
        if(QuantidadeParcelas__c == null || QuantidadeParcelas__c === 0 || valorParcela == null){
            return;
        }

        propostaSerie.valorTotal = QuantidadeParcelas__c * parseFloat(valorParcela);
    }

    calcularValorParcelaPropostaSerie(propostaSerie){

        const { QuantidadeParcelas__c, valorTotal } = propostaSerie;

        if(QuantidadeParcelas__c == null || QuantidadeParcelas__c == 0 || valorTotal == null){            
            return;
        }

        propostaSerie.valorParcela = parseFloat(valorTotal) / QuantidadeParcelas__c ;
    }

    calcularValorNominalProposta(){
        let valorNominalProposta = 0;

        this.propostasCliente.forEach(serie=>{
            valorNominalProposta += parseFloat(serie.valorTotal)
        })
        
        this.valorNominalProposta = parseFloat(valorNominalProposta);            
    }

    calcularPorcentagensProposta(){
         this.propostasCliente.forEach(serie=>{
            const {QuantidadeParcelas__c, valorParcela, valorTotal } = serie;
            if(QuantidadeParcelas__c == null || valorParcela == null){return;}

            let porcValorTotal = (valorTotal / this.valorNominalProposta) * 100;
            let porcParcela = porcValorTotal / QuantidadeParcelas__c;


            serie.ValorTotal__c = porcValorTotal ? `${(porcValorTotal).toFixed(2)}%` : '0.00%';
            serie.porcentagemParcela = porcParcela ? `${(porcParcela).toFixed(2)}%` : '0.00%';
         })    
    }

    igualarTabelas(){
        this.propostasCliente = this.seriesPagamentos;
        this.calcularFinanceiroProposta();
    }

    pagarAVista(event){
        const entradaPreco = event.detail;
        let propostasClienteClone = [];

        let dataAtual = new Date();
        let dataAtualFormatada = dataAtual.toISOString().split('T')[0];

        propostasClienteClone.push ({
            uid: this.generateUniqueId(),
            TipoCondicao__c: 'Ato',
            InicioPagamento__c: 0,
            vencimentoParcela: null,
            QuantidadeParcelas__c: 1,
            valorParcela: entradaPreco?.ValorVenda__c,
            valorTotal: entradaPreco?.ValorVenda__c,
            porcentagemParcela: null,
            ValorTotal__c: null,
        })

        this.propostasCliente = propostasClienteClone;

        this.calcularFinanceiroProposta();
    }

    aplicarDescontoProposta(event){
        const descontosSeries = event.detail;

        descontosSeries.forEach(descontoSerie =>{
            let serieProposta = this.propostasCliente.find(serie => serie.uid === descontoSerie.uid);

            serieProposta.valorTotal = descontoSerie.valorTotalComDesconto;
            serieProposta.valorParcela = serieProposta.valorTotal / serieProposta.QuantidadeParcelas__c;
           
        })

        this.propostasCliente = [...this.propostasCliente]

        this.calcularFinanceiroProposta();

        this.showNotification("Desconto aplicado!", "", "success")
    }

    calcularQtdParcela(seriePagamento){
        return seriePagamento.valorTotal / QuantidadeParcelas__c
    }

    calcularFinanceiroProposta(){
        this.calcularValorNominalProposta();
        this.calcularPorcentagensProposta();
        this.calcularDesconto();
    }

    generateUniqueId() {
        return 'id-' + Math.random().toString(36).substr(2, 9);
    }

    formatCurrency(value) {
        if (!value) return 'R$ 0,00';
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    }

    limparDadosSimulacao(){
        this.tabelaVendasVingenteValue = undefined;
        this.ultimaTabelaSelecionada = undefined;
        this.tabelaVendaSelecionada = undefined;
        this.seriesVendaTabelaSelecionada = undefined;
        this.tabelaVendasInfoComplementares = undefined;
        this.valorNominalTabelaSelecionada = undefined;
        this.valorVplTabelaSelecionada = undefined;
        this.propostasCliente = undefined;
        this.valorNominalProposta = undefined;
        this.valorVplProposta = undefined;
        this.idProdutoSelecionado = undefined;
    }

    concluirSimulacao(){
        let quoteLineItems = []
        let series = []
        let valorTotalPropostaUnidade = 0.0;
        let valorTotalVagas = 0.0;

        this.vagasSelecionadasInfo.forEach(vaga => {
            quoteLineItems.push({
                Quantity: 1,
                Product2Id: vaga.id,
                UnitPrice: vaga.valorVaga || 0.0,
                QuoteId: this.recordId
            })

            valorTotalVagas += vaga.valorVaga;
        })

        this.propostasCliente.forEach(serie=>{
            series.push({
                TipoCondicao__c: serie.TipoCondicao__c,
                InicioPagamento__c: serie.InicioPagamento__c,
                QuantidadeParcelas__c: serie.QuantidadeParcelas__c,
                Cotacao__c: this.recordId,
                ValorTotalNominal__c: serie.valorTotal,
                DiaVencimentoParcela__c: serie.vencimentoParcela
            })

            valorTotalPropostaUnidade += serie.valorTotal;
        })

        valorTotalPropostaUnidade -= valorTotalVagas;

        quoteLineItems.push({
            Quantity: 1,
            Product2Id: this.produtoSelecionado.id,
            UnitPrice: valorTotalPropostaUnidade,
            QuoteId: this.recordId
        })

        concluirSimulacao({idCotacao: this.recordId, isParaAprovacao: this.isParaAprovacao, series: series, qlis: quoteLineItems, valorUnidadeTabela: this.entradaPrecoSelecionada.ValorVenda__c})
        .then(() => {
            this.refreshQuoteData();
            this.showNotification("Sucesso", "Simulação concluída com sucesso", "success");
            this.simulacaoFinalizada = true;
        })
        .catch(error => {
            console.error(error);
            this.showNotification("Erro ao concluir simulacao", "Verifique os campos de entrada", "error");
        })
    }

    handleValorChange(event) {
        const { valorVaga, idVaga } = event.detail;
    
        const vagaIndex = this.vagasSelecionadasInfo.findIndex(vaga => vaga.id === idVaga);
        if (vagaIndex !== -1) {
            this.vagasSelecionadasInfo[vagaIndex].valorVaga = valorVaga;
        } else {
            this.vagasSelecionadasInfo.push({ id: idVaga, valorVaga });
        }
        
    }
    
    handleEnviarAprovacao(event) {
        this.isParaAprovacao = event.detail;
    }
}