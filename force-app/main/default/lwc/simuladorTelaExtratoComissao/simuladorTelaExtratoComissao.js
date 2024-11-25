import { LightningElement, api } from 'lwc';

const COMISSAO_COLUNAS = [
    { label: 'Nome', fieldName: 'nome' },
    { label: 'Cargo', fieldName: 'TeamMemberRole' },
    { label: 'Valor Comissão ($)', fieldName: 'ValorComissao__c' },
    { label: 'Valor Prêmio ($)', fieldName: 'ValorPremio__c' }
];

export default class SimuladorTelaExtratoComissao extends LightningElement {
    @api equipeVendas;
    @api valorDestinadoComissao;

    get equipe() {
        if(!this.equipeVendas) return [];

        return this.equipeVendas.map(membro => {
            return {
                nome: membro.User.Name,
                TeamMemberRole: membro.TeamMemberRole,
                ValorComissao__c: this.formatCurrency(this.getValorNominalComissao(membro)),
                ValorPremio__c: this.formatCurrency(membro.ValorPremio__c)
            }
        });
    }

    get totalComissao() {
        if(!this.equipeVendas) return 0;

        const totalComissao = this.equipeVendas.reduce((total, membro) => {
            return total + this.getValorNominalComissao(membro);
        }, 0);

        return this.formatCurrency(totalComissao);
    }
    
    get comissaoColunas() {
        return COMISSAO_COLUNAS;
    }

    getValorNominalComissao(membro) {
        return !membro.PercentualComissao__c
            ? membro.ValorComissao__c
            : this.valorDestinadoComissao * membro.PercentualComissao__c / 100;
    }

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