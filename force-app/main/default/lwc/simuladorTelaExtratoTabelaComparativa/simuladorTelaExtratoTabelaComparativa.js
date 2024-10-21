import { LightningElement, api, track } from 'lwc';
import calcularComparacao from '@salesforce/apex/ComparativoController.calcularComparacao';

const colunas = [
    { label: 'Item', fieldName: 'item' }, 
    { label: 'Tabela', fieldName: 'valorTabela', type: 'text' }, 
    { label: 'Proposta', fieldName: 'valorProposta', type: 'text' },
    { label: 'Diferença', fieldName: 'diferenca', type: 'text' } 
];

export default class SimuladorTelaExtratoTabelaComparativa extends LightningElement {
    @api propostasCliente = [];
    @api idTabelaVenda;

    @track comparacaoResultados = [];
    @track colunas = colunas;

    connectedCallback() {
        console.log('connectedCallback executed');
        console.log('PropostasCliente:', this.propostasCliente); 
        console.log('IdTabelaVenda:', this.idTabelaVenda); 
        this.carregarComparacao();
    }

    carregarComparacao() {
        if (this.propostasCliente && this.idTabelaVenda) {
            calcularComparacao({ tabelaId: this.idTabelaVenda, proposta: this.propostasCliente })
                .then(result => {
                    console.log('Apex Result:', result); 
                    
                    this.comparacaoResultados = result.map(item => {
                        console.log('Mapping Item:', item); 

                        const mappedItem = {
                            item: item.item,
                            valorTabela: this.formatValue(item.valorTabela, item.item),
                            valorProposta: this.formatValue(item.valorProposta, item.item),
                            diferenca: this.formatValue(item.diferenca, item.item)
                        };

                        console.log('Mapped Item:', mappedItem); 
                        return mappedItem;
                    });

                    console.log('Mapped Results:', this.comparacaoResultados); 
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
            '% de Captação até habite-se', 
            
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