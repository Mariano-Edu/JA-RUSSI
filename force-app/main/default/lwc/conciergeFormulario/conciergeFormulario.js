import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConciergeFormulario extends LightningElement {
    @api telaClienteEncontrado;
    @api telaClienteNaoEncontrado;
    @api ddis;
    @api recordTypes;
    @api formulario;

    connectedCallback() {
        this.handleEventDDI();
    };

    handleEventDDI() {
        this.dispatchEvent(new CustomEvent('defaultfields', {
            detail: {
                'ddiCel': 'Brasil (+55)',
                'ddiTel': 'Brasil (+55)'
            }
        }));
    }

    handleChange(event) {
        this.handleMascaras(event);
        
        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: event
        }));
    }

    handleMascaras(event) {
        if (event.target.dataset.name == 'celular' || event.target.dataset.name == 'telefone') this.aplicarMascaraPhone(event);
        if (event.target.dataset.name == 'dddCel' || event.target.dataset.name == 'dddTel') this.aplicarMascaraDDD(event);
    }

    aplicarMascaraPhone(event) {
        let value = event.target.value.replace(/\D/g, '');
        let valorFormatado = event.target.value.replace(/\D/g, '');

        if (value.length > 4) valorFormatado = `${value.slice(0, (value.length-4))}-${value.slice((value.length-4), value.length)}`;

        event.target.value = valorFormatado;
    }

    aplicarMascaraDDD(event) {
        event.target.value = event.target.value.replace(/\D/g, '').slice(0, 5);
    }

    handleConsultarLeads() {
        if (!this.formularioValidado()) { return; }

        this.dispatchEvent(new CustomEvent('consultarleads', {
            detail: {
                telaClienteEncontrado: this.telaClienteEncontrado,
                telaClienteNaoEncontrado: this.telaClienteNaoEncontrado
            }
        }));

    }

    formularioValidado() {
        return this.nomePreenchido() && this.nomeValido();
    }

    nomePreenchido() {
        if (!this.formulario.nome) { 
            this.apresentarMensagem('Atenção', 'É necessário preencher pelo menos o nome completo para a pesquisa', 'warning');
            return false; 
        }
        
        return true;
    }

    nomeValido() {
        const nome = this.formulario.nome.split(' ');

        if (nome.includes('')) {
            this.apresentarMensagem('Atenção', 'Insira um valor válido para o nome. Exemplo: [Nome Sobrenome]', 'warning');
            return false;
        }

        return true;
    }

    apresentarMensagem(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}