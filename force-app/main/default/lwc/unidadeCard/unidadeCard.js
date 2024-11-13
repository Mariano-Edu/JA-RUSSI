import { api, LightningElement, track } from 'lwc';

export default class UnidadeCard extends LightningElement {
    @api unidade;
    @api isInCotacao;
    @track cardSelecionado = false;

    get getCardClasses() {
        return `slds-clearfix slds-p-around_small slds-grid slds-grid_vertical unidadeCard ${this.cardSelecionado ? 'cardSelecionado' : ''}`;
    }

    renderedCallback() {
        console.log(this.isInCotacao);
    }

    @api
    setCardSelecionado(value) {
        this.cardSelecionado = value;
    }
    
    get getUnidadePreco(){
        return this.unidade && this.unidade.preco ? this.formatCurrency(this.unidade.preco) : this.formatCurrency(0.00);
    }
    
    get getUnidadeTipoUnidade(){
        //TODO Refatorar
        return this.unidade && this.unidade.tipoUnidade ? this.unidade.tipoUnidade : null;
    }

    get getUnidadeStatus() {
        return this.unidade.status
    }

    @api
    get getUnidadeName(){
        return this.unidade && this.unidade.name ? this.unidade.name : null;
    }

    

    get getUnidadeNumeroQuartos() {
        // TODO Refatorar
        return this.unidade && this.unidade.numeroQuartos 
            ? this.unidade.numeroQuartos === 1 
                ? `${this.unidade.numeroQuartos} Quarto` 
                : `Quartos ${this.unidade.numeroQuartos}` 
            : `0 quartos`;
    }


    get getUnidadeMetrosQuadrados(){
        return this.unidade && this.unidade.metrosQuadrados ?  `${this.unidade.metrosQuadrados.toFixed(2)} m²`  : `0 m²` ;
    }

    get getUnidadeSelected(){
        return this.unidade && this.unidade.selected ? this.unidade.selected : false
    }

    handleDetalhes() {
        window.open('/'+this.unidade.id)
    }

    handleSimulador() {
        //colocar url do simulador
        window.open('/');
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

}