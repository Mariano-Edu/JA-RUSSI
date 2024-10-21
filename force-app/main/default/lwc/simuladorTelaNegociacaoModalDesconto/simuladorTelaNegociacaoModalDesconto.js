import { api, LightningElement, track } from 'lwc';
import LightningModal from 'lightning/modal';

const tipoCondicoesColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c', sortable: true },
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency'},
    { label: '% Desconto aplicado', fieldName: 'porcDesconto', editable: true, cellAttributes: { alignment: 'right' }}, 
    { label: 'Valor do desconto', fieldName: 'valorDesconto', type: 'currency'},
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

    get getPorcentagemDesconto(){
        return this.procentagemDesconto;
    }

    get getValorDescontoTotal(){
        return this.valorDescontoTotal.toFixed(2);
    }

    get getValorNominal(){
        return parseFloat(this.valorNominalProposta).toFixed(2);
    }

    get getValorNominalComDesconto(){
        return parseFloat(this.valorNominalProposta - this.valorDescontoTotal).toFixed(2);
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
        console.log("entrou uma vez")
        if (this.propostasCliente && this.propostasVisiveis.length === 0) {
            console.log("entrou uma segunda vez")
            console.log("propostas cliente", JSON.stringify(this.propostasCliente))
            let propostasValidas = [];
            
            this.propostasCliente.forEach(serie=>{
                if(!serie.TipoCondicao__c || serie.valorTotal <= 0) {return;}
                propostasValidas.push(serie);
            })

            console.log("propostas validas", JSON.stringify(propostasValidas))

            this.propostasVisiveis = propostasValidas.length > 0 ? JSON.parse(JSON.stringify(propostasValidas)) : null;
        }
    }
    



    handlePorcentagemDesconto(event){
        this.procentagemDesconto = event.detail.value;
       
    }



    handleChangeSerie(event){
         this.serieSelecionadaUid = event.detail.value;
         this.limparValoresCalculo();

        if(this.serieSelecionadaUid === "todos"){
            this.propostasVisiveis = JSON.parse(JSON.stringify(this.propostasCliente)); 
            return;};
        


            this.propostasVisiveis = JSON.parse(JSON.stringify(this.propostasCliente.filter(proposta => proposta.uid === this.serieSelecionadaUid)));
    }

        limparValoresCalculo(){
            this.valorDesconto = 0;
            this.procentagemDesconto = null;
            this.valorDescontoTotal = 0;
        }

    handleFecharModal(){
            this.close();
        }


    handleSave(event){
        this.valorDescontoTotal = 0;
        
        const records = event.detail.draftValues.slice().map((draftValue) => {
            return Object.assign({}, draftValue);
          });

          this.draftValues = [];

          records.forEach(valorEditado=>{
            let serieEditada = this.propostasVisiveis.find(proposta =>(proposta.uid === valorEditado.uid));
            
            let valorDeDesconto = (serieEditada.valorTotal * (valorEditado.porcDesconto / 100));

            serieEditada.porcDesconto = valorEditado.porcDesconto ;
            serieEditada.valorDesconto = valorDeDesconto;
            serieEditada.valorTotalComDesconto = serieEditada.valorTotal - valorDeDesconto;

          })

        this.propostasVisiveis.forEach(serie=>{
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
        console.log(event)

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.propostasVisiveis];

        console.log(sortedBy, sortDirection)

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        
        console.log(JSON.stringify(cloneData));

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