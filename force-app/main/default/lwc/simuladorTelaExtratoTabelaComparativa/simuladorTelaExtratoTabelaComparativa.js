import { LightningElement, api, track } from 'lwc';
import calcularComparacao from '@salesforce/apex/ComparativoController.calcularComparacao';

const colunas = [
    { label: 'Item', fieldName: 'item' }, 
    { label: 'Tabela', fieldName: 'valorTabela', type: 'text' }, 
    { label: 'Proposta', fieldName: 'valorProposta', type: 'text' },
    { 
        label: 'Diferença', 
        fieldName: 'diferenca', 
        cellAttributes: {
            class: { 
                fieldName: 'diferencaClass'
            } 
        } 
    }
];

export default class SimuladorTelaExtratoTabelaComparativa extends LightningElement {
    @api propostasCliente = [];
    @api idTabelaVenda;
    @api idUnidade;

    @track comparacaoResultados = [];
    @track colunas = colunas;

    connectedCallback() {
        this.carregarComparacao();
    }

    carregarComparacao() {
        if (this.propostasCliente && this.idTabelaVenda) {
            this.propostasCliente = this.propostasCliente.map(proposta => ({...proposta, ValorTotalNominal__c: proposta.valorTotal}));
            calcularComparacao({ unidadeId: this.idUnidade, tabelaId: this.idTabelaVenda, proposta: this.propostasCliente })
                .then(result => {

                    this.comparacaoResultados = result.map(item => {
                        const mappedItem = {
                            item: item.item,
                            valorTabela: this.formatValue(item.valorTabela, item.item),
                            valorProposta: this.formatValue(item.valorProposta, item.item),
                            diferenca: this.formatValue(item.diferenca, item.item),
                            diferencaClass: (() => {
                                if (item.diferenca > 0) { 
                                    return 'slds-text-color_success' 
                                }
                                else if (item.diferenca < 0) { 
                                    return 'slds-text-color_error' 
                                }
                            })()
                        };
                        
                        return mappedItem;
                    });

                })
                .catch(error => {
                    console.error('Hata: ', error);
                });
        } else {
            console.error('PropostasCliente ou idTabelaVenda nao existe');
        }
    }

    formatValue(value, item) {
        
        const percentageItems = [
            'Desconto Percentual', 
            
        ];

        if (percentageItems.includes(item)) {
            return this.formatPercentage(value);
        } else {
            return this.formatCurrency(value);
        }
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('pt-BR', { 
            style: 'currency', 
            currency: 'BRL', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value);
    }

    formatPercentage(value) {
        return new Intl.NumberFormat('pt-BR', { 
            style: 'percent', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value / 100);
    }
}