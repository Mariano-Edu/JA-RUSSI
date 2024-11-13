import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class UnidadeInfoDisplay extends NavigationMixin(LightningElement) {
    @api produtoSelecionado;
    @api qtdVagasSelecionadas;
    @api vagasExtras;
    @api vagasSelecionadasInfo = [];
    @api valorRecebido;

    @api valorVaga;
    @track formattedValue = 'R$ 0,00';

    get hasVagasExtras() {
        return this.vagasExtras > 0;
    }
    
    connectedCallback(){
        this.template.addEventListener('valorchange', this.handleValorChange.bind(this));
    }

    handleValorChange(event) {
        this.valorVaga = event.detail.valorVaga;
        this.updateFormattedValue();
    }

    updateFormattedValue() {
        this.formattedValue = this.formatCurrency(this.valorVaga);
    }

    get formattedVagasSelecionadasInfo() {
        return this.vagasSelecionadasInfo.map(vaga => {
            return {
                ...vaga,
                valorVagaFormatado: this.formatCurrency(vaga.valorVaga)
            };
        });
    }

    get getValorVaga(){
        return this.valorVaga;
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

    get hasExtraVagas() {
        return this.vagasSelecionadasInfo.some(vaga => vaga.isExtra);
    }

    get isProdutoSelecionado(){
        return this.produtoSelecionado;
    }

    get produtoSelecionadoId(){
        return this.produtoSelecionado && this.produtoSelecionado.id ? this.produtoSelecionado.id : false;
    }

    redirectToEmpreendimento(){
        this[NavigationMixin.Navigate]( {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.produtoSelecionado.id,
                actionName: 'view'
            }
        });
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