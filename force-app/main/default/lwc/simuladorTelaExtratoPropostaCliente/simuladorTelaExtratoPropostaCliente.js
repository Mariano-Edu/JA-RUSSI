import { LightningElement, api } from 'lwc';

const propostaColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c'},
    { label: 'Dia de vencimento', fieldName: 'vencimentoParcela'},
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c'},
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency'},
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency'},
    { label: '% Parcela', fieldName: 'porcentagemParcela'},
    { label: '% Total', fieldName: 'ValorTotal__c'},    
];

export default class SimuladorTelaExtratoPropostaCliente extends LightningElement {
    @api condicoesPropostaCliente;
    @api idTabelaDeVendas;
    @api valoresMatriz;
    
    @api descontoNominal;
    @api descontoPercentual;

    get formattedValorNominal() {
        return this.formatCurrency(this.valoresMatriz.nominalProposta);
    }

    get formattedValorDescontoP() {
        return this.descontoNominal < 0 ? '-' : this.formatCurrency(this.descontoNominal);
    }

    get formattedValorDescontoN() {
        return this.descontoPercentual < 0 ? '-' : this.formatPercentage(this.descontoPercentual);
    }
    
    propostaColunas = propostaColunas;

    formatCurrency(value) {
        if (value == null || isNaN(value)) {
            return value;
        }
        return new Intl.NumberFormat('pt-BR', { 
            style: 'currency', 
            currency: 'BRL', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value);
    }

    formatPercentage(value) {
        if (value == null || isNaN(value)) {
            return value;
        }
        return new Intl.NumberFormat('pt-BR', { 
            style: 'percent', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value / 100);
    }
}