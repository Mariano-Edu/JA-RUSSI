import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import buscarBlocosPorEmpreendimento from '@salesforce/apex/EspelhoVendasController.buscarBlocosPorEmpreendimento';

export default class EspelhoDeVendas extends LightningElement {
    @track apartments = [];
    @track filteredApartments = [];
    @track blocoOptions = [];
    @track opportunityId;
    @api tabelaOptions;
    @api empreendimentoSelecionado;
    @api opportunitySelecionada;
    @api entradaPrecosMap;
    @api cotacaoId;

    disponivel;
    empreendimentoId;
    opportunityTipoVenda;

    @api
    get getTabelaOptions() {
        return this.tabelaOptions;
    }

    @api
    get getEntradaPrecosMap() {
        return this.entradaPrecosMap;
    }

    get getEmpreendimentoSelecionado() {
        return this.empreendimentoSelecionado;
    }

    get getFitleredApartments(){
        return this.filteredApartments;
    }

    get isDisponivel() {
        return this.disponivel === 1;
    }

    @wire(CurrentPageReference)
    pageRef({ state }) {
        if (!state) return;

        const newEmpreendimentoId = state?.c__empreendimentoId;
        
        const disponivel = state?.c__disponivel !== undefined 
            ? Number(state?.c__disponivel) 
            : 1;

        this.disponivel = disponivel;

        if(newEmpreendimentoId && newEmpreendimentoId !== this.empreendimentoId) {
            this.empreendimentoId = newEmpreendimentoId;
            this.handleIdEmpreendimentoChange();
        }

        const newOpportunityId = state?.c__opportunityId;
        if(newOpportunityId && newOpportunityId !== this.opportunityId) {
            this.opportunityId = newOpportunityId;
        }
        
    }

    renderedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const newEmpreendimentoId = urlParams.get('c__empreendimentoId');
        const newOpportunityId = urlParams.get('c__opportunityId');
        const disponivel = urlParams.get('c__disponivel') !== undefined 
            ? Number(urlParams.get('c__disponivel')) 
            : 1;

        if(newEmpreendimentoId && newEmpreendimentoId !== this.empreendimentoId) {
            this.empreendimentoId = newEmpreendimentoId;
            this.disponivel = disponivel;
            this.handleIdEmpreendimentoChange();
        }

        if(newOpportunityId && newOpportunityId !== this.opportunityId) {
            this.opportunityId = newOpportunityId
        };

    }

    handleIdEmpreendimentoChange() {
        this.empreendimentoSelecionado = this.empreendimentoId;
        // this.buscarTabelas(this.opportunitySelecionada);
    }

    selectEmpreendimento(event) {
        this.empreendimentoSelecionado = event.detail.idEmpreendimento;
        // this.buscarTabelas(this.opportunitySelecionada);
    }

    selectTabela(event) {
        this.tabelaSelecionada = event.detail.idTabela;
        this.dispatchEvent(new CustomEvent('selecionartabela', { detail: { idTabela: this.tabelaSelecionada, tabelaOptions: this.tabelaOptions } }));
    }

    changeApartments(event) {
        this.apartments = event.detail
    }

    handleFilterUpdate(event) {
        this.filteredApartments = event.detail;
    }

    get getFilteredApartments() {
        return this.filteredApartments;
    }
    
    selecionarUnidade(event){
        this.dispatchEvent(new CustomEvent('selecionarunidade', { detail: event.detail }));
    }

    @wire(buscarBlocosPorEmpreendimento, { 
        idEmpreendimento: '$empreendimentoSelecionado' 
    })
    wiredBlocos({ error, data }) {
        if (data) {
            const mappedOptions = data.map(bloco => ({
                label: bloco.Name,
                value: bloco.Id
            }));
            
            this.blocoOptions = [
                ...mappedOptions,
                { label: 'Todos', value: '' }
            ];
        } else if (error) {
            console.error('Erro ao buscar blocos: ', error);
        }
    }

    handleRecarregarEspelho() {
        this.filteredApartments = [];
        this.blocoOptions = [];
        this.tabelaOptions = [];
        this.opportunityTipoVenda = null;
        this.empreendimentoSelecionado = null;

        this.handleIdEmpreendimentoChange();
        // this.buscarTabelas(this.opportunitySelecionada);
    }
}