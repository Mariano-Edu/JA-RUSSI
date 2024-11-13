import { LightningElement, api } from 'lwc';

export default class SimuladorTelaExtrato extends LightningElement {
    @api propostasClienteData;
    @api idTabelaVendas;
    @api valoresMatriz;
    
    @api descontoNominal;
    @api descontoPercentual;

    valoresMatrizProposta;

    get getValoresMatrizProposta(){
        return this.valoresMatrizProposta;
    }

    get getIdUnidade() {
        return this.valoresMatriz?.entradaPrecoSelecionada?.Id;
    }

    get getDescontoNominal() {
        return this.descontoNominal;
    }

    get getDescontoPercentual() {
        return this.descontoPercentual;
    }

    connectedCallback(){
        if(!this.valoresMatriz) return;
    }
    
    handleEnviarAprovacao(event) {
        this.dispatchEvent(new CustomEvent('enviaraprovacao', { detail: event.detail }));
    }

}