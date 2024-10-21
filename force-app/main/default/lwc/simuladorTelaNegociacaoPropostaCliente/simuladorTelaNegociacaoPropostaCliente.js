import { LightningElement, api } from 'lwc';
import simuladorTelaNegociacaoModalDesconto from 'c/simuladorTelaNegociacaoModalDesconto';

export default class SimuladorTelaNegociacaoPropostaCliente extends LightningElement {
    colunas =[
        {
         fieldApiName: 'TipoCondicao__c',
         label: 'Tipo de Condição'   
        },
        {
         fieldApiName: 'InicioPagamento__c',
         label: 'Início de Pagamento'   
        },
        {
         fieldApiName: 'vencimentoParcela',
         label: 'Dia de vencimento'   
        },

        {
         fieldApiName: 'QuantidadeParcelas__c',
         label: 'Qtd. Parcelas'   
        },
        {
         fieldApiName: 'valorParcela',
         label: 'Valor parcela'   
        },
        {
         fieldApiName: 'valorTotal',
         label: 'Valor total',
         type: 'currency',
         typeAttributes: {
             currencyCode: 'BRL'
         }    
        },
        {
            fieldApiName: 'porcParcela',
            label: '% Parcela'   
        },
        {
            fieldApiName: 'porcTotal',
            label: '% Total', 
        },
        {
            fieldApiName: 'AposHabiteSe__c',
            label: 'Após habite-se?'   
        },
        {
         fieldApiName: 'actions',
         label: ''   
        }
    ]

    @api propostasClienteData = [];
    
    @api valorNominalPropostaData;
    @api valorVplPropostaData;

    @api unidadeSelecionada;



    addNewObjectWithUid() {
        this.dispatchEvent(new CustomEvent('adicionarcondicaodata'));
    }


    handleChangeCondicao(event){
        
        this.dispatchEvent(new CustomEvent('changecondicaodata', {
            detail: event.detail
        }));
    }

    handleDeleteCondicao(event){
        this.dispatchEvent(new CustomEvent('deletecondicaodata', {
            detail: event.detail
        }));
    }

    handleDeleteCondicao(event){
        this.dispatchEvent(new CustomEvent('deletecondicaodata', {
            detail: event.detail
        }));
    }

    handleZerarCondicao(event){
        this.dispatchEvent(new CustomEvent('zerarcondicao', {
            detail: event.detail
        }));
    }

    
    handleIgualarTabelas(){
        this.dispatchEvent(new CustomEvent('handleigualartabelas'));  
    }

    handlePagarAvista(){
        this.dispatchEvent(new CustomEvent('handlepagaravista')); 
    }

    gerarPropostasModeloDesconto(){
        if(!this.propostasClienteData){return};

        let propostasModeloDesconto = [];

        this.propostasClienteData.forEach(proposta =>{


            propostasModeloDesconto.push({
                uid: proposta.uid,
                TipoCondicao__c: proposta.TipoCondicao__c,
                valorTotal: proposta.valorTotal,
                porcDesconto: 0,
                valorDesconto: 0,
                valorTotalComDesconto: proposta.valorTotal
            })
        })

        return propostasModeloDesconto;
        
    }

    gerarTiposCondicoesOptions(){
        if(!this.propostasClienteData){return}

        let tiposCondicoesOptions = [];

        tiposCondicoesOptions.push({
            label: "Todos", value: "todos"
        })

        this.propostasClienteData.forEach(proposta=>{
            tiposCondicoesOptions.push({
                label: proposta.TipoCondicao__c, value: proposta.uid
            })
        })

        return tiposCondicoesOptions;
    }

    handleAplicarDesconto(event){
        const descontoEvent = new CustomEvent('aplicardesconto', {
            detail: event.detail
        });

        this.dispatchEvent(descontoEvent); 
    }

    async handleAbrirModalDesconto(){
        const result = await simuladorTelaNegociacaoModalDesconto.open({
            size: 'large',
            description: 'Modal para aplicação de desconto em series da proposta do cliente.',
            propostasCliente: this.gerarPropostasModeloDesconto(),
            valorNominalProposta: this.valorNominalPropostaData,
            tiposCondicoes: this.gerarTiposCondicoesOptions(),
            onaplicardesconto: (e) => {
                e.stopPropagation();
                this.handleAplicarDesconto(e);
              }
        });
        console.log(result);
    }

    
    get formattedValorNominal() {
        return this.formatCurrency(this.valorNominalPropostaData);
    }

    get formattedValorVPL() {
        return this.formatCurrency(this.valorVplPropostaData);
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