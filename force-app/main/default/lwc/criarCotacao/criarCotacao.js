import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import criarCotacaoPorOportunidade from '@salesforce/apex/CotacaoController.criarCotacaoPorOportunidade';

export default class CriarCotacao extends NavigationMixin(LightningElement) {
    @api recordId;
    @track loading;

    get isLoading() {
        return this.loading;
    }

    handleCancelar() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleConfirmar() {
        this.loading = true;
        criarCotacaoPorOportunidade({ opportunityId: this.recordId })
            .then((res) => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToast("Sucesso", `Cotação criada com sucesso`, "success")

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: res.Id,
                        objectApiName: 'Quote',
                        actionName: 'view'
                    }
                });
            })
            .catch((error) => {
                console.error(error);
                this.showToast("Erro", `Não foi possível criar cotação`, "error")
            })
            .finally(() => {
                this.loading = false;
            });
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