import { LightningElement, api } from 'lwc';

const propostaColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c'},
    { label: 'Dia de vencimento', fieldName: 'vencimentoParcela'},
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c'},
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency'},
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency'},
    { label: '% parcela', fieldName: 'porcentagemParcela'},
    { label: '% total', fieldName: 'ValorTotal__c'},    
];

export default class SimuladorTelaExtratoPropostaCliente extends LightningElement {
    @api condicoesPropostaCliente;
    @api idTabelaDeVendas;
    @api valoresMatriz;

    get getValorNominal() {
        return this.formatCurrency(this.valoresMatriz.nominalProposta);
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
}