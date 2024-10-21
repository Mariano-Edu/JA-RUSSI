import { LightningElement, api } from 'lwc';
import FishingDeals from '@salesforce/resourceUrl/FishingDeals';

export default class ConciergeConclusao extends LightningElement {
    @api telaPesquisar;

    imagem = FishingDeals;

    handlePesquisar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaPesquisar }
        }));
    }
}