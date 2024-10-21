import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api } from 'lwc';
import criarLead from '@salesforce/apex/ConciergeController.criarLead';

export default class ConciergeCriacao extends LightningElement {
    @api telaCancelar;
    @api telaCriar;
    @api origens;
    @api ddis;
    @api canais;
    @api formulario;
    @api roleta;
    @api recordTypes;
    @api midias;

    connectedCallback() {
        this.handleEventRecordType();
    }

    handleEventRecordType() {
        this.dispatchEvent(new CustomEvent('defaultfields', {
            detail: {
                'recordTypeId': this.recordTypes[0]
            }
        }));
    }

    handleChange(event) {
        this.handleMascaras(event);
        
        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: event
        }));
    }

    get isLeadPf() {
        return this.formulario.recordType && this.recordTypes.some(recordType => recordType.value === this.formulario.recordType && recordType.label === 'Pessoa Física');
    }

    get isLeadPj() {
        return this.formulario.recordType && this.recordTypes.filter(recordType => recordType.value === this.formulario.recordType)[0].label === 'Pessoa Jurídica';
    }

    handleCriarLead() {
        if (!this.camposValidados()) return;

        criarLead({ formulario: this.formulario })
            .then(idLead => {
                window.open('/'+idLead);

                this.handleCancelar();
            })
            .catch(e => {

                console.log(e);

                let mensagem = '';

                if(e.body.pageErrors) {
                    for(const value of e.body.pageErrors) {
                        mensagem += value.message;
                    }
                }

                if(e.body.fieldErrors) {
                    for(const field in e.body.fieldErrors) {
                        for(const error of e.body.fieldErrors[field]) {
                            mensagem += error.message;
                        }
                    }
                }


                this.apresentarMensagem('Erro', mensagem, 'error');
            })
    }

    camposValidados() {
        const campoTelefoneNulo = !this.formulario.telefone && !this.formulario.dddTel;
        const campoCelularNulo = !this.formulario.celular && !this.formulario.dddCel;

        campoCelularNulo && this.dispatchEvent(
            new CustomEvent('setformulariofield', {
                    detail: {
                        field: 'ddiCel',
                        value: null
                    }
                }
            )
        );

        campoTelefoneNulo && this.dispatchEvent(
            new CustomEvent('setformulariofield', {
                    detail: {
                        field: 'ddiTel',
                        value: null
                    }
                }
            )
        );

        const campoTelefoneValido = campoTelefoneNulo || this.campoTelefoneValido();
        const campoCelularValido = campoCelularNulo || this.campoCelulaValido();

        return this.formasContatoValidas() &&
            this.nomesPreenchidos() &&
            this.camposSelecaoPreenchidos() &&
            campoCelularValido &&
            campoTelefoneValido;
    }

    camposSelecaoPreenchidos() {
        return this.validarCampoSelecao('recordType', 'Tipo de Registro') &&
            this.validarCampoSelecao('origem', 'Origem do lead') &&
            this.validarCampoSelecao('midia', 'Mídia atual') &&
            this.validarCampoSelecao('canal', 'Canal de atendimento');
    }

    validarCampoSelecao(field, alias) {
        if(!this.formulario[field]) {
            this.apresentarMensagem('Atenção' , `Atenção, o campo ${alias} é obrigatório`, 'warning');
            return false;
        }

        return true;
    }

    campoCelulaValido() {
        const celularNulo = !this.formulario.celular;
        const dddNulo = !this.formulario.dddCel;
        
        const campoCelularInvalido = (!celularNulo && dddNulo) || (celularNulo && !dddNulo);
        if(campoCelularInvalido) {
            this.apresentarMensagem(
                'Atenção',
                `Preencha o campo ${celularNulo ? 'Celular' : 'DDD Celular'}`,
                'warning'
            );

            return false;
        }

        return true;
    }

    campoTelefoneValido() {
        const telefoneNulo = !this.formulario.telefone;
        const dddNulo = !this.formulario.dddTel;

        const campoTelefoneInvalido = (!telefoneNulo && dddNulo) || (telefoneNulo && !dddNulo);
        if(campoTelefoneInvalido) {
            this.apresentarMensagem(
                'Atenção',
                `Preencha o campo ${telefoneNulo ? 'Telefone' : 'DDD Telefone'}`,
                'warning'
            );

            return false;
        }

        return true;
    }

    formasContatoValidas() {
        const numerosVazios = !this.formulario.celular && !this.formulario.telefone;
        
        if(numerosVazios && !this.formulario.email) {
            this.apresentarMensagem(
                'Atenção',
                `Preencha pelo menos um dos seguintes campos: Celular, Email ou Telefone`,
                'warning'
            );

            return false;
        }

        return !this.formulario.email || this.emailValido();
    }

    emailValido() {
        let regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

        if (!regex.test(this.formulario.email)) {
            this.apresentarMensagem('Atenção', 'O email não está em um formato inválido.', 'warning');
            return false;
        }

        return true;
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

    nomesPreenchidos() {
        if(!this.formulario.nome) return false;

        if(this.formulario.nome.length > 250) {
            this.apresentarMensagem('Atenção', 'O nome não pode ter mais de 250 caracteres.', 'warning');
            return false;
        }

        if(this.isLeadPj) {
            if(!this.formulario.empresa) {
                this.apresentarMensagem('Atenção', 'O nome da empresa é obrigatório', 'warning');
                return false;
            }

            if(this.formulario.empresa.length > 250) {
                this.apresentarMensagem('Atenção', 'O nome da empresa não pode ter mais de 250 caracteres.', 'warning');
                return false;
            }
        }

        return true;
    }

    apresentarMensagem(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });

        this.dispatchEvent(toastEvent);
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('limparform', {
            detail: {
                nome: null,
                email: null,
                ddiCel: null,
                dddCel: null,
                empresa: null,
                celular: null,
                ddiTel: null,
                dddTel: null,
                telefone: null,
                midia: null,
                origem: null,
                canal: null,
                recordType: null,
                idUsuario: null
            }
        }));

        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }
}