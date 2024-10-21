import { LightningElement, api } from 'lwc';

export default class SimuladorTelaExtrato extends LightningElement {
    @api propostasClienteData;
    @api idTabelaVendas;
    @api valoresMatriz;

    valoresMatrizProposta;

    get getValoresMatrizProposta(){
        return this.valoresMatrizProposta;
    }

    connectedCallback(){
        if(!this.valoresMatriz) {return;}

        this.valoresMatrizProposta = {
                                      nominalProposta: this.valoresMatriz.nominalProposta,
                                      vplProposta: this.valoresMatriz.valorVplProposta
                                     }
    }

}