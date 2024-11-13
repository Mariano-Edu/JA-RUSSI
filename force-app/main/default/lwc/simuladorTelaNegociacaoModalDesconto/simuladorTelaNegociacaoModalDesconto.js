import { api, LightningElement, track } from 'lwc';
import LightningModal from 'lightning/modal';

const tipoCondicoesColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c', sortable: true },
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency'},
    { 
        label: 'Desconto percentual', 
        fieldName: 'porcDesconto',  
        type: 'number',
        typeAttributes: {
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        },
        editable: true, 
        cellAttributes: { 
            alignment: 'right' 
        }
    }, 
    { label: 'Desconto nominal', fieldName: 'nomDesconto', editable: true, cellAttributes: { alignment: 'right' }, type: 'currency'}, 
    { label: 'Valor total com desconto', fieldName: 'valorTotalComDesconto', type: 'currency'}
];

export default class SimuladorTelaNegociacaoModalDesconto extends LightningModal{
    @api propostasCliente;
    @api valorNominalProposta;
    @api tiposCondicoes;

    @track propostasVisiveis = [];
    @track procentagemDesconto; 
    @track serieSelecionadaUid = "todos";
    @track valorDescontoTotal = 0;
    @track valorNominalComDesconto = 0;
    @track seriesSelecionadas = []

    draftValues = []
    tipoCondicoesColunas = tipoCondicoesColunas;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;


    get getSerieSelecionada(){
        return this.serieSelecionadaUid; 
    }
    
    get propostasVisiveisGet() {
        return this.propostasVisiveis;
    }
    
    get getValoresModal() {
        // return this.propostasVisiveis.map(proposta => ({...proposta, porcDesconto: 0.0}));
        return this.propostasVisiveis;
    }

    get getPorcentagemDesconto(){
        return this.procentagemDesconto;
    }

    get getValorDescontoTotal(){
        return this.formatCurrency(this.valorDescontoTotal);
    }

    get getValorNominal(){
        return this.formatCurrency(this.valorNominalProposta);
    }

    get getValorNominalComDesconto(){
        return this.formatCurrency(this.valorNominalProposta - this.valorDescontoTotal);
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

    get isDescontoValido(){
        let serieSelecionada = this.propostasVisiveis.find(proposta => proposta.uid === this.serieSelecionadaUid);
        return serieSelecionada && serieSelecionada.valorTotal - this.valorDescontoTotal > 0;
    }

    get getSerieSelecionadaObjeto(){
        return this.propostasVisiveis.find(proposta => proposta.uid === this.serieSelecionadaUid)
    }

    get isSerieTodos(){
        return this.serieSelecionadaUid === "todos"
    }

    renderedCallback() {
        if (this.propostasCliente && this.propostasVisiveis.length === 0) {
            let propostasValidas = [];
            
            this.propostasCliente.forEach(serie=>{
                if(!serie.TipoCondicao__c || serie.valorTotal <= 0) {return;}
                propostasValidas.push(serie);
            })

            this.propostasVisiveis = propostasValidas.length > 0 ? JSON.parse(JSON.stringify(propostasValidas)) : null;
        }
    }
    

    handlePorcentagemDesconto(event){
        this.procentagemDesconto = event.detail.value;
    }

    handleChangeSerie(event){
        this.serieSelecionadaUid = event.detail.value;
        this.limparValoresCalculo();

        if (this.serieSelecionadaUid === "todos") {
            this.propostasVisiveis = JSON.parse(JSON.stringify(this.propostasCliente)); 
            return;
        };
        
        this.propostasVisiveis = JSON.parse(JSON.stringify(this.propostasCliente.filter(proposta => proposta.uid === this.serieSelecionadaUid)));
    }

    limparValoresCalculo() {
        this.valorDesconto = 0;
        this.procentagemDesconto = null;
        this.valorDescontoTotal = 0;
    }

    handleFecharModal() {
        this.close();
    }


    handleSave(event) {
        const records = event.detail.draftValues.slice().map((draftValue) => {
            return Object.assign({}, draftValue);
        });

        this.draftValues = [];

        records.forEach( valorEditado => {
            let serieEditada = this.propostasVisiveis.find(proposta =>(proposta.uid === valorEditado.uid));
            
            const chaves = Object.keys(valorEditado);
            if (chaves.includes("porcDesconto") && chaves.includes("nomDesconto")) {
                console.error('Não é possível alterar ambos de uma vez');
                return;
            }
            
            let valorEditadoPorcDesconto = (valorEditado.porcDesconto || valorEditado.nomDesconto / (serieEditada.valorTotal / 100.0));
            let valorEditadoNomDesconto = valorEditado.nomDesconto || serieEditada.valorTotal * (valorEditado.porcDesconto / 100.0);

            serieEditada.porcDesconto = Number(valorEditadoPorcDesconto).toFixed(2);
            serieEditada.nomDesconto = valorEditadoNomDesconto;
            serieEditada.valorTotalComDesconto = serieEditada.valorTotal - valorEditadoNomDesconto;
        })

        this.propostasVisiveis.forEach(serie => {
            this.valorDescontoTotal += serie.valorDesconto;
        })
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.propostasVisiveis];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

        this.propostasVisiveis = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleSalvarPropostas(){
        const descontoEvent = new CustomEvent('aplicardesconto', {
            detail: this.propostasVisiveis
        });

        this.dispatchEvent(descontoEvent); 

        this.handleFecharModal();
    }
}