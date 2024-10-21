import { api, LightningElement, track } from 'lwc';

export default class SimuladorTelaNegociacaoInfoComplementares extends LightningElement {
    @api infoComplementares

    @track taxaTp;
    @track taxaDescontoVpl;
    @track antecipacaoAteHabitase;
    @track antecipacaoAposHabitase;


    get getTaxaTp(){
        return this.infoComplementares && this.infoComplementares.taxaTp ? this.infoComplementares.taxaTp : 0;
    }

    get getTaxaDescontoVpl(){
        return this.infoComplementares && this.infoComplementares.taxaDescontoVpl ? this.infoComplementares.taxaDescontoVpl : 0;
    }

    get getAntecipacaoAteHabitase(){
        return this.infoComplementares && this.infoComplementares.antecipacaoAteHabitase ? this.infoComplementares.antecipacaoAteHabitase : 0;
    }

    get getAntecipacaoAposHabitase(){
        return this.infoComplementares && this.infoComplementares.antecipacaoAposHabitase ? this.infoComplementares.antecipacaoAposHabitase : 0;
    }

}