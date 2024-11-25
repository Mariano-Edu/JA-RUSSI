import { LightningElement, api, track } from 'lwc';

export default class EquipeVendas extends LightningElement {
    @api tabelasComissao;
    @api equipeOpp;
    @api equipeVendas;
    @api precoSemPermuta;
    @track tabelaComissaoSelecionada;
    valorPremio;
    percentualComissao;

    connectedCallback() {
        this.tabelaComissaoSelecionada = this.tabelasComissao[0].Id;
        this.percentualComissao = this.tabelasComissao[0].PercentualComissao__c;
        this.valorPremio = this.tabelasComissao[0].ValorPremio__c;
        this.dispatchEvent(new CustomEvent('selectcomissao', { detail: this.tabelaComissaoSelecionada }));
    }

    get getTabelasComissaoOptions() {
        return this.tabelasComissao.map(tabela => {
            return {
                label: tabela.Name,
                value: tabela.Id
            }
        });
    }

    get valorTotalFormatado() {
        return this.formatarValorMonetario(this.totalComissao);
    }

    get totalComissao() {
        return this.equipeVendas.reduce((total, membro) => {
            if(!membro.PercentualComissao__c) return total + membro.ValorComissao__c;
            return total + this.precoSemPermuta * membro.PercentualComissao__c / 100
        }, 0);
    }

    get valorDestinadoComissaoFormatado() {
        return this.formatarValorMonetario(this.valorDestinadoComissao);
    }

    get valorDestinadoComissao() {
        return this.precoSemPermuta * this.percentualComissao / 100;
    }

    get valorRestanteFormatado() {
        return this.formatarValorMonetario(this.valorRestanteComissao);
    }

    get valorRestanteComissao() {
        return this.valorDestinadoComissao - this.totalComissao;
    }

    handleChangeComissao(event) {
        const value = event.detail.recordId;
        
        if(!value) {
            return;
        }

        this.tabelaComissaoSelecionada = value;

        const tabela = this.tabelasComissao.find(tabela => tabela.Id === this.tabelaComissaoSelecionada);

        this.percentualComissao = tabela.PercentualComissao__c;
        this.valorPremio = tabela.ValorPremio__c;

        this.dispatchEvent(new CustomEvent('selectcomissao', { detail: this.tabelaComissaoSelecionada }));
    }

    handleAtualizarRestante(event) {
        this.valorRestanteComissao = event.detail;
    }

    handleMembroChange(event) {
        this.equipeVenda = event.detail;
        this.dispatchEvent('equipevendaschange', { detail: this.equipeVenda })
    }

    adicionarMembro() {
        this.dispatchEvent(new CustomEvent('adicionarmembro'));
    }

    handleAtualizarEquipe(event) {
        this.equipeVendas = event.detail;
        this.dispatchEvent(new CustomEvent('atualizarequipe', event))
    }
    
    formatarValorMonetario(value) {
        if (!value) return 'R$ 0,00';

        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    }
}