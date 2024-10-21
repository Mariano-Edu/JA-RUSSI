import { LightningElement, api, track } from 'lwc';
import obterSeriesPorIdTabela from '@salesforce/apex/SimuladorTelaNegociacaoController.obterSeriesPorIdTabela';
import calcularTotalVPL from '@salesforce/apex/CotacaoController.calcularTotalVPLTabela';

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
    { label: '% parcela', fieldName: 'porcentagemParcela' },
    { label: '% total', fieldName: 'ValorTotal__c' },
    { label: 'Após habite-se?', fieldName: 'AposHabiteSe__c', type: 'boolean' }
];

export default class SimuladorTelaNegociacaoTabelaVendas extends LightningElement {
    tabelaVendasColunas = tabelaVendasColunas;

    @track tabelaVendasOptions = [];
    @api tabelasVendas;
    @api tabelaVingenteValue;
    @api ultimaTabelaSelecionada;

    @track seriePagamentosTabelaVendas = [];
    @track tabelaVendaSelecionada;
    @track tabelaVendaValue;
    @track inicioVigenciaTabela;
    @track fimVigenciaTabela;
    @track valorNominal;
    @track valorVPL;

    @track unidadeTabelaVendasSelecionada;
    @api unidadeSelecionada;

    get getTabelasVendas(){
        return this.tabelasVendas;
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
        return this.formatCurrency(this.valorNominal);
    }

    get formattedValorVPL() {
        return this.formatCurrency(this.valorVPL);
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

    connectedCallback() {
        this.gerarTabelaVendasOptions();
        this.selecionarTabelaPadrao();
    }

    gerarTabelaVendasOptions() {
        let tabelaVendasOptions = [];

        console.log(JSON.stringify(this.getTabelasVendas));
        

        if (!this.getTabelasVendas) {
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
        if(this.tabelasVendas.length === 0){return;}

        let tabelaSelecionadaObject = this.tabelasVendas.find(tabela => tabela.Id === idTabela);
        
        
        this.tabelaVendaSelecionada = tabelaSelecionadaObject;

        this.tabelaVendaValue = idTabela;

        console.log(JSON.stringify('this.tabelaVendaSelecionada'));
        console.log(JSON.stringify(this.tabelaVendaSelecionada));

        console.log(JSON.stringify(this.tabelaVendaSelecionada.VigenciaInicio__c), JSON.stringify(this.tabelaVendaSelecionada.VigenciaFim__c))
        
        this.inicioVigenciaTabela = this.tabelaVendaSelecionada.VigenciaInicio__c ? formatData(this.tabelaVendaSelecionada.VigenciaInicio__c) : null;
        this.fimVigenciaTabela = this.tabelaVendaSelecionada.VigenciaFim__c ? formatData(this.tabelaVendaSelecionada.VigenciaFim__c) : null;

        // this.obterSeriesPorIdTabela();
    }

    setTabelaSelecionada(tabelaSelecionada, seriesPagamento, valorNominal, valorVpl) {
        this.dispatchEvent(new CustomEvent('settabelaselecionada', {
            detail: { tabelaSelecionada: tabelaSelecionada, seriesPagamento: seriesPagamento, valorNominalTabela: valorNominal, valorVplTabela: valorVpl }
        }));
    }

    obterSeriesPorIdTabela() {
        obterSeriesPorIdTabela({ idTabela: this.getTabelaVendaSelecionadaId })
            .then(result => {
                this.calcularValoresTabela(this.getTabelaVendaSelecionadaId, result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    selecionarTabelaVingente() {
        if (!this.tabelaVingenteValue) {
            return;
        }

        console.log('aqui')
        const { idTabelaVingente, valorNominal, valorVPL } = this.tabelaVingenteValue;

        this.selecionarTabela(idTabelaVingente);
        this.valorNominal = valorNominal;
        this.valorVPL = valorVPL;
    }

    selecionarTabelaPadrao() {
        if (!this.ultimaTabelaSelecionada) {
            this.selecionarTabelaVingente();
            return;
        }


        const { tabelaVendaSelecionada, seriesTabela, valorNominal, valorVpl } = this.ultimaTabelaSelecionada;

        this.selecionarTabela(tabelaVendaSelecionada.Id);
        this.seriePagamentosTabelaVendas = seriesTabela;
        this.valorNominal = valorNominal;
        this.valorVPL = valorVpl;
    }

    calcularValoresTabela(idTabelaSelecionada, seriesPagamentoTabela) {
        calcularTotalVPL({ idTabelaVendas: idTabelaSelecionada })
            .then(result => {
                this.valorVPL = result.valorVPL ? result.valorVPL : 0;
                this.valorNominal = result.valorNominal ? result.valorNominal : 0;

                this.calcularFinanceiroSerie(seriesPagamentoTabela);
            })
            .catch(error => {
                console.log(error);
            });
    }

    calcularFinanceiroSerie(seriesPagamentoTabela) {
        let seriesPagamentos = [];

        seriesPagamentoTabela.forEach(element => {
            let porcParcela = calcularPorcParcelaSeriePagamento(element.ValorTotal__c, element.QuantidadeParcelas__c);
            let valorParcela = calcularValorParcelaSeriePagamento(porcParcela, this.valorNominal);
            let valorTotal = calcularValorTotalSeriePagamento(element.ValorTotal__c, this.valorNominal);

            seriesPagamentos.push({
                uid: this.generateUniqueId(),
                TipoCondicao__c: element.TipoCondicao__c,
                InicioPagamento__c: calcularInicioPagamentoSeriePagamentos(element),
                vencimentoParcela: null,
                QuantidadeParcelas__c: element.QuantidadeParcelas__c,
                ValorTotal__c: (element.ValorTotal__c).toFixed(2) + '%',
                AposHabiteSe__c: element.AposHabiteSe__c,
                porcentagemParcela: porcParcela.toFixed(2) + '%',
                valorParcela: valorParcela.toFixed(2),
                valorTotal: valorTotal
            });
        });

        this.seriePagamentosTabelaVendas = seriesPagamentos;

        this.setTabelaSelecionada(this.tabelaVendaSelecionada, this.seriePagamentosTabelaVendas, this.valorNominal, this.valorVPL);
    }

    generateUniqueId() {
        return 'id-' + Math.random().toString(36).substr(2, 9);
    }
}