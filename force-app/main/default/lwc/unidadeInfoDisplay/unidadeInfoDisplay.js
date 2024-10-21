import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class UnidadeInfoDisplay extends NavigationMixin(LightningElement) {
    @api produtoSelecionado;
    
    connectedCallback(){
        console.log(JSON.stringify(this.produtoSelecionado))
    }

    get produtoSelecionadoEmpreendimento(){
        return this.produtoSelecionado && this.produtoSelecionado.empreendimento ? this.produtoSelecionado.empreendimento : false;
    }

    get produtoSelecionadoNomeTorre(){
        return this.produtoSelecionado && this.produtoSelecionado.bloco ? this.produtoSelecionado.bloco : false;
    }

    get produtoSelecionadoName(){
        return this.produtoSelecionado && this.produtoSelecionado.name ? this.produtoSelecionado.name : false;
    }

    get produtoSelecionadoNumeroUnidade(){
        return this.produtoSelecionado && this.produtoSelecionado.numeroUnidade? this.produtoSelecionado.numeroUnidade: false;
    }

    get produtoSelecionadoFamiliaProduto(){
        return this.produtoSelecionado && this.produtoSelecionado.tipoUnidade ? this.produtoSelecionado.tipoUnidade : false;
    }


    get produtoSelecionadoAndar(){
        return this.produtoSelecionado && this.produtoSelecionado.andar ? this.produtoSelecionado.andar : false;
    }

    get produtoSelecionadoQuartos(){
        return this.produtoSelecionado && this.produtoSelecionado.numeroQuartos ? this.produtoSelecionado.numeroQuartos : false;
    }

    get produtoSelecionadoMetragemUnidade(){
        return this.produtoSelecionado && this.produtoSelecionado.metrosQuadrados ? this.produtoSelecionado.metrosQuadrados : false;
    }

    get produtoSelecionadoPrecoLista(){
        return this.produtoSelecionado && this.produtoSelecionado.preco ? this.formatCurrency(this.produtoSelecionado.preco) : false;
    }

    get isProdutoSelecionado(){
        return this.produtoSelecionado;
    }

    get produtoSelecionadoId(){
        return this.produtoSelecionado && this.produtoSelecionado.id ? this.produtoSelecionado.id : false;
    }

    redirectToEmpreendimento(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.produtoSelecionado.id,
                actionName: 'view'
                }
        })
    }
    formatCurrency(value) {
        return new Intl.NumberFormat('pt-BR', { 
            style: 'currency', 
            currency: 'BRL', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value);

    }
}