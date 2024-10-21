import { api, LightningElement, track, wire  } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TIPO_CONDICAO_FIELD from "@salesforce/schema/SeriePagamentos__c.TipoCondicao__c";



    

export default class CustomDataTable extends LightningElement {
    @api header =[];
    @api series = [];
    @api unidadeSelecionada;

    @track vencimentoParcelaOptions = [];
    tipoCondicoesPickList;
    
    connectedCallback(){
        this.generateDiasVencimentoOptions();
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: TIPO_CONDICAO_FIELD })
    result({error, data}){
        if(data){
            this.tipoCondicoesPickList = data.values
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.tipoCondicoesPickList = undefined;
          }
    };

    get getColunasHeader(){
        return this.header;
    }
    
    get getSeriesPagamentosObjetos(){
        return this.series;
    }

    generateDiasVencimentoOptions(){
        console.log(JSON.stringify(this.unidadeSelecionada))

        if(!this.unidadeSelecionada.DiasDeVencimentoDaParcela){return}
        let diasVencimento = this.unidadeSelecionada.DiasDeVencimentoDaParcela;
        let diasVencimentoArray = diasVencimento.split(';');


        diasVencimentoArray.forEach(diaDeVencimento => {
            this.vencimentoParcelaOptions.push({
                label: 'Dia ' + diaDeVencimento,
                value: diaDeVencimento
            });
        });
        
    }

    handleChange(event){
        const target = event.currentTarget;
 

        this.dispatchEvent(new CustomEvent('mudancacondicao', {
            detail: {uid: target.dataset.uid, name: target.dataset.name, type: target.type, value: target.value ? target.value : null, checked: target.checked ? target.checked : null}
        }));
    }

    handleDelete(event){
        const target = event.currentTarget; 
        this.dispatchEvent(new CustomEvent('deletecondicao', {
            detail: {uid: target.dataset.uid}
        }));
    }

    handleZerar(event){
        const target = event.currentTarget;

        this.dispatchEvent(new CustomEvent('zerarcondicao', {
            detail: {uid: target.dataset.uid}
        }));
    }








}