import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import getMotivos from '@salesforce/apex/LeadController.getMotivosPerda';
import alterarStatusParaPerdido from '@salesforce/apex/LeadController.alterarStatusParaPerdido';

export default class LeadPerdidoBtn extends LightningElement {
    @api motivo;
    motivos = [];
    recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) this.recordId = currentPageReference.state.recordId;
    }

    connectedCallback() {      
        this.getMotivos();
    }

    handleChange(event) {
        this.motivo = event.target.value;
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    getMotivos() {
        getMotivos()
            .then(motivo => {
                this.motivos = Object.keys(motivo).map(opcao => {
                    return {
                        label: motivo[opcao],
                        value: opcao
                    };
                });
            })
            .catch(erro => console.log('Erro ao obter motivos: ' + erro));
    }

    handleConfirm() {
        if(!this.motivo) {
            this.showNotification('Erro', 'Selecione o motivo da perda', 'error');
            return;
        }

        alterarStatusParaPerdido({ idLead: this.recordId, motivo: this.motivo })
            .then(() => this.showNotification('Sucesso', 'Status alterado para perdido com sucesso', 'success'))
            .catch(() => this.showNotification('Erro', 'Ocorreu um erro ao tentar alterar o status para perdido', 'error'))
            .finally(() => {
                this.closeModal();

                setTimeout(() => {
                    location.reload();
                }, 2000)
            })
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant}));
    }
}