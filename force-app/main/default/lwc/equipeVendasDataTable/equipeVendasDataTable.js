import { api, LightningElement, track, wire  } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import obterUsuarios from '@salesforce/apex/UserController.getUsersById';

import podeEditarComissao from '@salesforce/customPermission/ComissaoEdicaoComissao';
import podeEditarPremio from '@salesforce/customPermission/ComissaoPremio';

import CARGO_FIELD from "@salesforce/schema/OpportunityTeamMember.TeamMemberRole";

const MEMBRO_COLUNAS = [
    { label: 'Nome', fieldName: 'UserId' },
    { label: 'Cargo', fieldName: 'TeamMemberRole' },
    { label: 'Valor Comissão ($)', fieldName: 'ValorComissao__c' },
    { label: 'Percentual Comissão (%)', fieldName: 'PercentualComissao__c' },
    { label: 'Valor Prêmio ($)', fieldName: 'ValorPremio__c' }
];

export default class EquipeVendasDataTable extends LightningElement {
    @api equipeVendas;
    @api valorNominal;
    @api valorDestinadoComissao;
    @api percentualTotal;
    @api valorTotalPremio;
    @api totalComissao;
    @api precoSemPermuta;
    cargosOpt;
    cargos;
    usuarios;
    usuariosCadastrados = {};

    connectedCallback() {
        this.equipeVendas.forEach(membro => this.usuariosCadastrados[membro.uid] = membro.UserId);
    }

    get getColunasHeader() {
        return MEMBRO_COLUNAS;
    }
    
    get getEquipe() {
        return this.equipeVendas.map(membro => {
            return {
                uid: membro.uid,
                UserId: membro.User.Id || null,
                TeamMemberRole: membro.TeamMemberRole,
                ValorComissao__c: membro.ValorComissao__c || null,
                PercentualComissao__c: membro.PercentualComissao__c || null,
                ValorPremio__c: membro.ValorPremio__c || null,
                edicaoPercentualBloqueada: !podeEditarComissao || membro.ValorComissao__c,
                edicaoValorBloqueada: !podeEditarComissao || membro.PercentualComissao__c,
                naoPodeEditarPremio: !podeEditarPremio || membro.possuiValorPremio
            }
        });
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CARGO_FIELD })
    result({ data }) {
        if(data){
            this.cargos = data.values;

            this.cargosOpt = this.cargos.map(cargo => {
                return {
                    label: cargo.label,
                    value: cargo.value
                }
            });
        }
    }

    @wire(obterUsuarios)
    wiredUsuarios({ data }) {
        if(!data) return;
        this.usuarios = data;
    }

    validarPercentualComissao(event) {
        const { uid } = event.currentTarget.dataset;
        const porcentagem = Number(event.currentTarget.value);
        const valorAntigo = this.equipeVendas.find(membro => membro.uid === uid).PercentualComissao__c;

        if((porcentagem - valorAntigo) + this.somarCampo('PercentualComissao__c') > this.percentualTotal) {
            this.showNotification(
                'Atenção',
                `A soma das porcentagens de comisão não pode ultrapassar ${this.percentualTotal}%`,
                'warning'
            );
            event.currentTarget.value = valorAntigo;
            return;
        }

        const valorNominalAtualizado = this.precoSemPermuta * porcentagem / 100;
        const valorNominalAntigo = this.precoSemPermuta * valorAntigo / 100;

        if(valorNominalAtualizado + this.totalComissao - valorNominalAntigo > this.valorDestinadoComissao) {
            this.showNotification('Atenção', 'Os valores cadastrados excedem o valor destinado a comissão', 'warning');
            event.currentTarget.value = valorAntigo;
            return;
        }

        this.handleMembroChange(event);
    }

    validarValorComissao(event) {
        const { uid } = event.currentTarget.dataset;
        const valorComissao = Number(event.currentTarget.value);
        const valorAntigo = this.equipeVendas.find(membro => membro.uid === uid).ValorComissao__c;

        if(valorComissao + this.totalComissao - valorAntigo > this.valorDestinadoComissao) {
            this.showNotification('Atenção', 'Os valores cadastrados excedem o valor destinado a comissão', 'warning');
            event.currentTarget.value = valorAntigo;
            return;
        }
        
        this.handleMembroChange(event);
    }

    validarValorPremio(event) {
        const { uid } = event.currentTarget.dataset;
        const valorAtual = Number(event.currentTarget.value);
        const valorAntigo = this.equipeVendas.find(membro => membro.uid === uid).ValorPremio__c; 

        if((valorAtual - valorAntigo) + this.somarCampo('ValorPremio__c')  > this.valorTotalPremio) {
            this.showNotification('Atenção', 'Os valores cadastrados excedem o valor do prêmio', 'warning');
            event.currentTarget.value = valorAntigo;
            return;
        }

        this.handleMembroChange(event);
    }

    validarUsuario(event) {
        const { recordId } = event.detail;

        if(!recordId) return;

        const usuario = this.usuarios[recordId];
        const { uid } = event.currentTarget.dataset;

        const usuarioCadastrado = Object.keys(this.usuariosCadastrados).some(uid => usuario.Id === this.usuariosCadastrados[uid]);

        if(usuarioCadastrado) {
            this.showNotification('Atenção', 'Usuário já presente na equipe', 'warning');
            event.detail.recordId = null;
            return;
        }

        if(uid in this.usuariosCadastrados) {
            this.usuariosCadastrados[uid] = usuario.Id;
        }

        this.equipeVendas = this.equipeVendas.map(membro => {
            if(membro.uid !== uid) return membro;

            return {
                ...membro,
                User: usuario,
                UserId: usuario.Id
            }
        })

        this.atualizarEquipe();
    }

    handleMembroChange(event) {
        const { uid, name } = event.currentTarget.dataset;

        const valor = name === 'PercentualComissao__c' || name === 'ValorComissao__c' 
            ? Number(event.currentTarget.value) 
            : event.currentTarget.value;

        this.equipeVendas = this.equipeVendas.map(membro => {
            if(membro.uid !== uid) return membro;

            return {
                ...membro,
                [name]: valor
            }
        });

        this.atualizarEquipe();
    }

    handleDeleteMembroEquipe(event) {
        const { uid } = event.currentTarget.dataset;
        this.equipeVendas = this.equipeVendas.filter(membro => membro.uid !== uid);
        this.atualizarEquipe();
    }

    atualizarEquipe() {
        this.dispatchEvent(new CustomEvent('atualizarequipe', { detail: this.equipeVendas }));
    }

    showNotification(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    somarCampo(propriedade) {
        return this.equipeVendas.reduce((total, membro) => {
            return total + (!membro[propriedade] ? 0 : Number(membro[propriedade]));
        }, 0);
    }
}