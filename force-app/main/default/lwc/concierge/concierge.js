import criarLead from '@salesforce/apex/ConciergeController.criarLead';
import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import LEAD_OBJECT from '@salesforce/schema/Lead'
import obterCanaisAtendimento from '@salesforce/apex/ConciergeController.obterCanaisAtendimento';
import obterLeadsPorInformacoesConcierge from '@salesforce/apex/ConciergeController.obterLeadsPorInformacoesConcierge';
import obterOrigens from '@salesforce/apex/ConciergeController.obterOrigens';
import obterDDIs from '@salesforce/apex/ConciergeController.obterDDIs';
import obterMidias from '@salesforce/apex/ConciergeController.obterMidias';

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
        midia: null,
        origem: null,
        canal: null,
        recordType: null,
        idUsuario: null
    };

    leads = [];
    canais = [];
    origens = [];
    ddis = [];
    roletasLeads = [];
    midias = [];

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

    @track recordTypes;

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT }) 
    obterLeadRecordTypes(objectInfo, error){
        if(error) {
            console.log(error)
            return;
        }

        if(!objectInfo) return;
        
        const recordTypeInfo = objectInfo?.data?.recordTypeInfos;

        recordTypeInfo && console.log(JSON.stringify(recordTypeInfo));

        if(recordTypeInfo)
            this.recordTypes = Object.keys(recordTypeInfo)
                .filter(key => !recordTypeInfo[key].master && recordTypeInfo[key].available)
                .map(key => {
                    return {
                        label: recordTypeInfo[key].name,
                        value: recordTypeInfo[key].recordTypeId
                    }
                });
        
    }
        
    connectedCallback() {
        this.obterOrigens();
        this.obterDDIs();
        this.obterCanaisAtendimento();
        this.obterMidias();
    }

    handleLimparForm(event) {
        this.formulario = event.detail;
    }

    handleDefaultfields(event) {
        if (event.detail.ddiCel && this.formulario.ddiCel == null) this.formulario.ddiCel = event.detail.ddiCel;
        if (event.detail.ddiTel && this.formulario.ddiTel == null) this.formulario.ddiTel = event.detail.ddiTel;
        if (event.detail.recordTypeId && this.formulario.recordType == null) this.formulario.recordType = event.detail.recordTypeId.value;
    }

    obterOrigens() {
        obterOrigens()
            .then(origens => {
                this.origens = Object.keys(origens).map(opcao => {
                    return {
                        label: origens[opcao],
                        value: opcao
                    };
                });
            })
            .catch(erro => console.log('Erro ao obter origens: ' + erro));
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

    obterMidias() {
        obterMidias()
            .then(midias => {
                this.midias = Object.keys(midias).map(opcao => {
                    return {
                        label: midias[opcao],
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
            .then(leads => {
                this.roletasLeads = JSON.parse(leads);
                //this.handleMudancaTela(event);
            })
            .catch(erro => {
                console.error('Erro ao obter leads: ' + erro);
            });

    }

    handleDistribuirLeads(event) {
        this.handleMudancaTela(event);
    }

    handleConfirmarDistribuicao(event) {
        criarLead({ formulario: this.formulario })
            .then(() => {
                console.log('Lead criado com sucesso.');
                this.handleMudancaTela(event);
            })
            .catch(erro => {
                console.error('Erro ao criar lead: ' + JSON.stringify(erro));
            });
    }
    
    setFormularioField(event) {
        this.formulario[event.detail.field] = event.detail.value;
    }
}