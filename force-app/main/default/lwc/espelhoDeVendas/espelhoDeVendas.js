import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import buscarBlocosPorEmpreendimento from '@salesforce/apex/EspelhoVendasController.buscarBlocosPorEmpreendimento';

export default class EspelhoDeVendas extends LightningElement {
    @track apartments = [];
    @track filteredApartments = [];
    @track blocoOptions = [];
    @track empreendimentoSelecionado;
    disponivel;
    recordId;

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
    pageRef(newPageRef) {
        if(newPageRef) {
            const pageReference = newPageRef.state;
            const newRecordId = pageReference?.c__recordId;
            
            const disponivel = pageReference?.c__disponivel !== undefined 
                ? Number(pageReference?.c__disponivel) 
                : 1;

            this.disponivel = disponivel;

            if(newRecordId && newRecordId !== this.recordId) {
                this.recordId = newRecordId;
                this.handleIdEmpreendimentoChange();
            }
        }
    }

    renderedCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const newRecordId = urlParams.get('c__recordId');
        const disponivel = urlParams.get('c__disponivel') !== undefined 
            ? Number(urlParams.get('c__disponivel')) 
            : 1;

        if(newRecordId && newRecordId !== this.recordId) {
            this.recordId = newRecordId;
            this.disponivel = disponivel;
            this.handleIdEmpreendimentoChange();
        }
    }

    handleIdEmpreendimentoChange() {
        this.empreendimentoSelecionado = this.recordId;
        this.buscarBlocos();
    }

    selectEmpreendimento(event) {
        this.empreendimentoSelecionado = event.detail.idEmpreendimento;
        this.buscarBlocos();
    }

    changeApartments(event) {
        this.apartments = event.detail
    }

    handleFilterUpdate(event) {
        this.filteredApartments = event.detail;
    }

    handleRecarregarEspelho() {
        location.reload();
    }
    
    selecionarUnidade(event){
        this.dispatchEvent(new CustomEvent('selecionarunidade', { detail: event.detail }));
    }

    buscarBlocos(){
        buscarBlocosPorEmpreendimento({ idEmpreendimento: this.empreendimentoSelecionado })
            .then(response => {
                this.blocoOptions = response.map(bloco => {
                    return {
                        'label': bloco.Name,
                        'value': bloco.Id
                    }
                });
            })
    }
}