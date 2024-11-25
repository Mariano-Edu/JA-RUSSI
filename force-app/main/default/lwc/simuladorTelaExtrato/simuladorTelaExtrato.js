import { LightningElement, api } from 'lwc';

export default class SimuladorTelaExtrato extends LightningElement {
    @api propostasClienteData;
    @api idTabelaVendas;
    @api valoresMatriz;
    @api valorDestinadoComissao;
    @api equipeVendas;

    valoresMatrizProposta;

    get getValoresMatrizProposta(){
        return this.valoresMatrizProposta;
    }

    get getIdUnidade() {
        return this.valoresMatriz?.entradaPrecoSelecionada?.Id;
    }

    connectedCallback(){
        if(!this.valoresMatriz) return;
    }
    
    handleEnviarAprovacao(event) {
        this.dispatchEvent(new CustomEvent('enviaraprovacao', { detail: event.detail }));
    }

}