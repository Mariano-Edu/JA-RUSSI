import { LightningElement, api, track } from 'lwc';
import obterSeriesPorIdTabela from '@salesforce/apex/SimuladorTelaNegociacaoController.obterSeriesPorIdTabela';

import {
    formatData,
    calcularInicioPagamentoSeriePagamentos,
    calcularPorcParcelaSeriePagamento,
    calcularValorParcelaSeriePagamento,
    calcularValorTotalSeriePagamento
} from 'c/utils';

const tabelaVendasColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c' },
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c', type: 'number' },
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency' },
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency' },
    { label: '% Parcela', fieldName: 'porcentagemParcela' },
    { label: '% Total', fieldName: 'ValorTotal__c' }
];

export default class SimuladorTelaNegociacaoTabelaVendas extends LightningElement {
    tabelaVendasColunas = tabelaVendasColunas;

    @track tabelaVendasOptions = [];
    @api tabelasVendas;
    @api tabelaOptions;
    @api tabelaVingenteValue;
    @api ultimaTabelaSelecionada;
    @api tabelaSelecionada;

    @track seriePagamentosTabelaVendas = [];
    @track tabelaVendaSelecionada;
    @track tabelaVendaValue;
    @track inicioVigenciaTabela;
    @track fimVigenciaTabela;
    @track valorNominal;
    @track valorVPL = 0;

    @track unidadeTabelaVendasSelecionada;
    @api unidadeSelecionada;

    @api tabelaVendas;

    @api produtoSelecionado;
    @api entradaPrecosMap;

    get getTabelaVendas(){
        return this.tabelaVendas;
    }

    @api tabelaMesVigencia;

    get getTabelaMesVigencia(){
        return this.tabelaMesVigencia;
    }

    get getTabelaOptions(){
        return this.tabelaOptions;
    }

    get getTabelaVendaValue() {
        return this.tabelaVendaValue;
    }

    get getTabelaVendasOptions() {
        return this.tabelaVendasOptions;
    }

    get getTabelaVendaSelecionada() {
        return this.tabelaVendaSelecionada;
    }

    get getTabelaVendaSelecionadaId() {
        return this.tabelaVendaSelecionada.Id;
    }

    get getIdEmpreendimento() {
        return this.unidadeSelecionada.idEmpreendimento;
    }

    get getIdUnidade() {
        return this.unidadeSelecionada.idUnidade;
    }

    get formattedValorNominal() {
        return this.formatCurrency(this.entradaPrecosMap.ValorVenda__c);
    }

    get formattedValorDescontoP() {
        return this.formatPercentage(100 - this.entradaPrecosMap.ValorMinimoVenda__c * 100 / this.entradaPrecosMap.ValorVenda__c);
    }

    get formattedValorDescontoN() {
        return this.formatCurrency(this.entradaPrecosMap.ValorVenda__c - this.entradaPrecosMap.ValorMinimoVenda__c);
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

    formatPercentage(value) {
        if (value == null || isNaN(value)) {
            return value;
        }
        return new Intl.NumberFormat('pt-BR', { 
            style: 'percent', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value / 100);
    }

    connectedCallback() {
        this.selecionarTabelaPadrao();
    }

    gerarTabelaVendasOptions() {
        let tabelaVendasOptions = [];
        
        if (!this.tabelasVendas) {
            return;
        }

        this.tabelasVendas.forEach(element => {
            tabelaVendasOptions.push({ label: element.Name, value: element.Id });
        });

        this.tabelaVendasOptions = tabelaVendasOptions;
    }

    handleChangeTabela(event) {
        let idTabela = event.detail.value;
        this.selecionarTabela(idTabela);
    }

    selecionarTabela(idTabela) {
        if(this.tabelasVendas.length === 0) return;

        let tabelaSelecionadaObject = this.tabelasVendas.find(tabela => tabela.Id === idTabela);
        
        
        this.tabelaVendaSelecionada = tabelaSelecionadaObject;
        this.tabelaVendaValue = idTabela;

        this.inicioVigenciaTabela = this.tabelaVendaSelecionada.VigenciaInicio__c ? formatData(this.tabelaVendaSelecionada.VigenciaInicio__c) : null;
        this.fimVigenciaTabela = this.tabelaVendaSelecionada.VigenciaFim__c ? formatData(this.tabelaVendaSelecionada.VigenciaFim__c) : null;
    }

    setTabelaSelecionada(tabelaSelecionada, seriesPagamento, valorNominal, valorVpl) {
        this.dispatchEvent(new CustomEvent('settabelaselecionada', {
            detail: { tabelaSelecionada: tabelaSelecionada, seriesPagamento: seriesPagamento, valorNominalTabela: valorNominal, valorVplTabela: valorVpl }
        }));
    }

    // renderedCallback() {
    //     this.obterSeriesPorIdTabela();
    // }

    obterSeriesPorIdTabela() {

        obterSeriesPorIdTabela({ idTabela: this.tabelaVendaSelecionada?.Id })
            .then(result => {

                this.calcularFinanceiroSerie(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    selecionarTabelaPadrao() {
        this.tabelaVendaValue = this.tabelaSelecionada;
        this.tabelaVendaSelecionada = this.tabelaVendas.find(tabela => tabela.Id === this.tabelaVendaValue);
        
        if (this.tabelaVendaSelecionada) this.obterSeriesPorIdTabela();
    }

    calcularFinanceiroSerie(seriesPagamentoTabela) {
        let seriesPagamentos = [];

        seriesPagamentoTabela.forEach(element => {
            
            let porcParcela = calcularPorcParcelaSeriePagamento(element.ValorTotal__c, element.QuantidadeParcelas__c);
            let valorParcela = calcularValorParcelaSeriePagamento(porcParcela, this.entradaPrecosMap.ValorVenda__c);
            let valorTotal = calcularValorTotalSeriePagamento(element.ValorTotal__c, this.entradaPrecosMap.ValorVenda__c);

            seriesPagamentos.push({
                uid: this.generateUniqueId(),
                TipoCondicao__c: element.TipoCondicao__c,
                InicioPagamento__c: element.InicioPagamento__c,
                vencimentoParcela: null,
                QuantidadeParcelas__c: element.QuantidadeParcelas__c,
                ValorTotal__c: (element.ValorTotal__c).toFixed(2) + '%',
                porcentagemParcela: porcParcela.toFixed(2) + '%',
                valorParcela: valorParcela.toFixed(2),
                valorTotal: valorTotal
            });
        });

        this.seriePagamentosTabelaVendas = seriesPagamentos;

        this.dispatchEvent(new CustomEvent('selecionarserie', {
            detail: seriesPagamentos
        }));

        this.setTabelaSelecionada(this.tabelaVendaSelecionada, this.seriePagamentosTabelaVendas, this.valorNominal, this.valorVPL);
    }

    generateUniqueId() {
        return 'id-' + Math.random().toString(36).substr(2, 9);
    }
}