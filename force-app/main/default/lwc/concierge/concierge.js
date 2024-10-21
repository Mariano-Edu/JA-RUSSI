import { LightningElement, track } from 'lwc';
import criarLead from '@salesforce/apex/ConciergeController.criarLead';
import obterCanaisAtendimento from '@salesforce/apex/ConciergeController.obterCanaisAtendimento';
import obterLeadsPorInformacoesConcierge from '@salesforce/apex/ConciergeController.obterLeadsPorInformacoesConcierge';
import obterDDIs from '@salesforce/apex/ConciergeController.obterDDIs';
import obterLeadRecordTypes from '@salesforce/apex/ConciergeController.obterLeadRecordTypes'

const TELA_FORMULARIO = 'FORMULARIO';
const TELA_CLIENTE_NAO_ENCONTRADO = 'CLIENTE_NAO_ENCONTRADO';
const TELA_CLIENTE_ENCONTRADO = 'CLIENTE_ENCONTRADO';
const TELA_CRIAR_CLIENTE = 'CRIAR_CLIENTE';
const TELA_DISTRIBUICAO = 'DISTRIBUICAO';
const TELA_DISTRIBUICAO_REALIZADA = 'DISTRIBUICAO_REALIZADA';

export default class Concierge extends LightningElement {
    @track formulario = {
        nome: null,
        empresa: null,
        email: null,
        ddiCel: null,
        dddCel: null,
        celular: null,
        ddiTel: null,
        dddTel: null,
        telefone: null,
        canal: null,
        recordType: null,
        idUsuario: null
    };

    leads = [];
    canais = [];
    ddis = [];
    roletasLeads = [];
    @track recordTypes;

    telaAtual = TELA_FORMULARIO;
    
    tela = {
        formulario: TELA_FORMULARIO,
        clienteNaoEncontrado: TELA_CLIENTE_NAO_ENCONTRADO,
        clienteEncontrado: TELA_CLIENTE_ENCONTRADO,
        criarCliente: TELA_CRIAR_CLIENTE,
        distribuicao: TELA_DISTRIBUICAO,
        distribuicaoRealizada: TELA_DISTRIBUICAO_REALIZADA
    };

    get telaFormulario() {
        return this.telaAtual === this.tela.formulario;
    }

    get telaClienteNaoEncontrado() {
        return this.telaAtual === this.tela.clienteNaoEncontrado;
    }

    get telaClienteEncontrado() {
        return this.telaAtual === this.tela.clienteEncontrado;
    }

    get telaCriarCliente() {
        return this.telaAtual === this.tela.criarCliente;
    }

    get telaDistribuicao() {
        return this.telaAtual === this.tela.distribuicao;
    }

    get telaDistribuicaoRealizada() {
        return this.telaAtual === this.tela.distribuicaoRealizada;
    }

    
    connectedCallback() {
        this.obterDDIs();
        this.obterCanaisAtendimento();
        this.obterRecordTypes();
    }

    obterRecordTypes() {
        obterLeadRecordTypes()
            .then(recordTypes => {
                this.recordTypes = JSON.parse(recordTypes)
                    .map(recordType => { return { label: recordType.Name, value: recordType.Id } });
            })
            .catch(e => console.error(e))
    }

    handleLimparForm(event) {
        this.formulario = event.detail;
    }

    handleDefaultfields(event) {
        if (event.detail.ddiCel && this.formulario.ddiCel == null) this.formulario.ddiCel = event.detail.ddiCel;
        if (event.detail.ddiTel && this.formulario.ddiTel == null) this.formulario.ddiTel = event.detail.ddiTel;
        if (event.detail.recordTypeId && this.formulario.recordType == null) this.formulario.recordType = event.detail.recordTypeId.value;
    }

    obterDDIs() {
        obterDDIs()
        .then(ddis => {
                this.ddis = Object.keys(ddis).map(opcao => {
                    return {
                        label: ddis[opcao],
                        value: opcao
                    };
                });
            
                this.ddis.unshift({ label: 'Nenhum', value: null });
            })
            .catch(erro => console.log('Erro ao obter DDIs: ' + erro));
    }

    obterCanaisAtendimento() {
        obterCanaisAtendimento()
            .then(canais => {
                this.canais = Object.keys(canais).map(opcao => {
                    return {
                        label: canais[opcao],
                        value: opcao
                    };
                });
            })
            .catch(erro => console.log('Erro ao obter canais de atendimento: ' + erro));
    }

    handleMudancaTela(event) {
        this.telaAtual = event.detail.tela;
    }

    handleMudancaFormulario(event) {
        this.formulario[event.detail.target.dataset.name] = event.detail.target.value;
    }

    handleConsultarLeads(event) {
        obterLeadsPorInformacoesConcierge({ formulario: this.formulario })
            .then(leads => {
                this.leads = JSON.parse(leads);
                
                this.handleMudancaTela({
                    detail: {
                        tela: this.leads.length > 0
                            ? event.detail.telaClienteEncontrado
                            : event.detail.telaClienteNaoEncontrado
                    }
                });
            })
            .catch(erro => {
                console.error('Erro ao obter leads: ' + erro);
            });
    }

    handleCriarLead(event) {
        obterLeadsPorInformacoesConcierge({ formulario: this.formulario })
            .then(leads => this.roletasLeads = JSON.parse(leads))
            .catch(erro => console.error('Erro ao obter leads: ' + erro));
    }

    handleDistribuirLeads(event) {
        this.handleMudancaTela(event);
    }

    handleConfirmarDistribuicao(event) {
        criarLead({ formulario: this.formulario })
            .then(() => this.handleMudancaTela(event))
            .catch(erro => console.error('Erro ao criar lead: ' + JSON.stringify(erro)))
    }
    
    setFormularioField(event) {
        this.formulario[event.detail.field] = event.detail.value;
    }
}