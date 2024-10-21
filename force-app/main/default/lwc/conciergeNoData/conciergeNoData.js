import { LightningElement, api } from 'lwc';
import Desert from '@salesforce/resourceUrl/Desert';

export default class ConciergeNoData extends LightningElement {
    @api telaCancelar;
    @api telaCriar;

    imagem = Desert;

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('limparform', {
            detail: {
                nome: null,
                email: null,
                ddiCel: null,
                ddiTel: null,
                celular: null,
                origem: null,
                canal: null,
                idUsuario: null
            }
        }));

        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }

    handleCriar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCriar }
        }));
    }
}