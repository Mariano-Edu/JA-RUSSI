import { LightningElement, api } from 'lwc';

const propostaColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c'},
    { label: 'Dia de vencimento', fieldName: 'vencimentoParcela'},
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c'},
    { label: 'Valor Parcela ', fieldName: 'valorParcela'}, //não achei
    { label: 'Valor Total', fieldName: 'valorTotal'},//não achei
    { label: '% parcela', fieldName: 'porcentagemParcela'}, // não achei
    { label: '% total', fieldName: 'ValorTotal__c'},
    { label: 'Após habite-se?', fieldName: 'AposHabiteSe__c', type: 'boolean' }
    
];

export default class SimuladorTelaExtratoPropostaCliente extends LightningElement {
    @api condicoesPropostaCliente;
    @api idTabelaDeVendas;
    
    propostaColunas = propostaColunas;


}