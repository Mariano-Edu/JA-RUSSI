import { LightningElement, track, api } from 'lwc';

export default class ConciergeTabelaRoleta extends LightningElement {
    @api telaCancelar;
    @api telaDistribuir;
    @api formulario;

    @api 
    set roletasLeads(data) {
        this._roletasLeads = data;
    }

    get roletasLeads() {
        return this._roletasLeads;
    }

    @track error;
    @track searchString;
    @track initialRecords;

    _roletasLeads = [];

    colunas = [
        { label: "Nome", fieldName: "nome", type: "text" },
        { label: "Email", fieldName: "email", type: "email" },
        { label: "Celular", fieldName: "celular", type: "phone" },
        { label: "Status", fieldName: "status", type: "text" },
        { label: "Proprietário", fieldName: "proprietario", type: "text" }
    ];

    handleFiltrar(event) {
        this._roletasLeads = this._roletasLeads.filter(lead => lead.nome?.includes(event.detail.value));
    }

    getSelectedRows(event){
        const roleta = event.detail.selectedRows[0];

        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: {           
                target: {
                    value: roleta.id,
                    dataset: {
                        name: 'idRoletaLeads'
                    }
                }
            }
        }));
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }

    handleDistribuirLeads() {
        this.dispatchEvent(new CustomEvent('confirmardistribuicao', {
            detail: {
                tela: this.telaDistribuir
            }
        }));
    }
}