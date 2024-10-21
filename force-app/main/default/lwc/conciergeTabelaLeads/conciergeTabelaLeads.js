import { LightningElement, api, wire } from 'lwc';
import { IsConsoleNavigation, openTab } from 'lightning/platformWorkspaceApi';

export default class ConciergeTabelaLeads extends LightningElement {
    @wire(IsConsoleNavigation) isConsoleNavigation;
    
    @api telaCancelar;
    @api telaDistribuir;

    @api
    set leads(data) {
        this._leads = data;
        this.leadsConsultados = data;
    }

    get leads() {
        return this._leads;
    }

    leadsConsultados;
    _leads;


    
    colunas = [
        { label: "Nome", fieldName: "nome", type: "text" },
        { label: "Empresa", fieldName: "empresa", type: "text" },
        { label: "Email", fieldName: "email", type: "email" },
        { label: "Celular", fieldName: "celular", type: "phone" },
        { label: "Telefone", fieldName: "telefone", type: "text" },
        { label: "Status", fieldName: "status", type: "text" },
        { label: "Proprietário", fieldName: "proprietario", type: "text" },
    ];

    handleFiltrar(event) {
        const inputValue = event.detail.value;

        this._leads = inputValue !== '' 
            ? this._leads.filter(lead => lead.nome?.includes(inputValue))
            : this.leadsConsultados;
    }

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: {           
                target: {
                    value: selectedRows,
                    dataset: {
                        name: 'leads'
                    }
                }
            }
        }));
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('limparform', {
            detail: {
                nome: null,
                email: null,
                ddiCel: null,
                ddiTel: null,
                dddCel: null,
                dddTel: null,
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

    handleDetalhesLead() {
        const lead = this.template.querySelector("lightning-datatable").getSelectedRows()[0];
        window.open('/'+lead.id);
    }
}