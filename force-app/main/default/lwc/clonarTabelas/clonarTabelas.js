import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import NAME_FIELD from '@salesforce/schema/TabelaVendas__c.Name';
import PERCENTUAL_ACRESCIMO_FIELD from '@salesforce/schema/TabelaVendas__c.PercentualDeAcrescimo__c';
import VIGENCIA_INICIO_FIELD from '@salesforce/schema/TabelaVendas__c.VigenciaInicio__c';
import VIGENCIA_FIM_FIELD from '@salesforce/schema/TabelaVendas__c.VigenciaFim__c';

import clonarTabela from '@salesforce/apex/TabelaVendaController.clonarTabela';

const CAMPOS = [
    NAME_FIELD,
    PERCENTUAL_ACRESCIMO_FIELD,
    VIGENCIA_INICIO_FIELD,
    VIGENCIA_FIM_FIELD
];

const CAMPOS_OBRIGATORIOS = new Set([
    NAME_FIELD.fieldApiName,
    VIGENCIA_INICIO_FIELD.fieldApiName,
    VIGENCIA_FIM_FIELD.fieldApiName
])

export default class TabelaVenda extends LightningElement {
    @track nomeTabela;

    @api recordId;
    @api objectApiName;

    tabelaVendas = {};
    schema = {};


    get campos() {
        return CAMPOS.map(campo => {
            return { 
                apiName: campo.fieldApiName,
                isObrigatorio: CAMPOS_OBRIGATORIOS.has(campo.fieldApiName)
            };
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: CAMPOS })
    loadRecord({ data, error }) {
        if(error) {
            this.showToast('Erro', 'Erro ao carregar o registro', 'error');
            this.handleCancelar();
            return;
        }

        if(data) {
            this.nomeTabela = data.fields['Name'].value;

            CAMPOS.forEach(
                campo => this.tabelaVendas[campo.fieldApiName] = data.fields[campo.fieldApiName].value
            )
        }
        
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({ data, error }) {
        if (error) {
            console.error(error);
            return;
        }

        if (data) {
            CAMPOS_OBRIGATORIOS.forEach(campo => {
                this.schema[campo] = data.fields[campo].label;
            });
        }
    }

 handleClonarTabela() {
        clonarTabela({ tabelaVendas: this.tabelaVendas, idTabela: this.recordId })
            .then(result => {
                this.showToast('Tabela Clonada com sucesso');
                window.location.href = `/lightning/r/TabelaVendas__c/${result}/view`;
            })
            .catch(error => {   
                let errorMessage = 'Ocorreu um erro ao clonar a tabela';
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Erro', errorMessage, 'error');
            });
    }

    handleInputChange(event) {
        this.tabelaVendas[event.target.dataset.field] = event.target.value;
    }

    tabelaInvalida() {
        let tabelaInvalida = this.validarCamposObrigatorios();

        if(this.tabelaVendas.Name === this.nomeTabela) {
            this.showToast('Atenção', 'O nome da tabela clonada não pode ser o mesmo da original', 'warning');
            tabelaInvalida = true;
        }
        
        if(this.tabelaVendas.Name === this.nomeTabela) {
            this.showToast('Atenção', 'O nome da tabela clonada não pode ser o mesmo da original', 'warning');
            tabelaInvalida = true;
        }

        return tabelaInvalida;
    }

    validarCamposObrigatorios() {
        let tabelaInvalida = false;

        CAMPOS_OBRIGATORIOS.forEach(campo => {
            if(!this.tabelaVendas[campo]) {
                this.showToast('Atenção', `O campo "${this.schema[campo]}" é obrigatório`, 'warning');
                tabelaInvalida = true;
            }
        })

        return tabelaInvalida;
    }
    

    handleCancelar() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}