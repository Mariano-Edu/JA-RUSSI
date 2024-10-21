import { LightningElement, track } from 'lwc';

export default class EspelhoVendasFiltrosExtras extends LightningElement {
    @track metragem = 0;
    @track valor = 0;
    @track quantidadeQuartos = 0;
    @track quantidadeSuites = 0;
    @track tipoUnidade = '';
    
    @track tipoUnidadeOptions = [
        { label: 'Apartamento', value: 'Apartamento' },
        { label: 'Cobertura', value: 'Cobertura' },
        { label: 'Loft', value: 'Loft' }
    ];

    @track selectedFilters = [];

    handleMetragemChange(event) {
        this.metragem = event.target.value;
        this.updateFilters('Metragem', this.metragem);
    }

    handleValorChange(event) {
        this.valor = event.target.value;
        this.updateFilters('Valor', this.valor);
    }

    handleQuantidadeQuartosChange(event) {
        this.quantidadeQuartos = event.target.value;
        this.updateFilters('Quantidade de Quartos', this.quantidadeQuartos);
    }

    handleQuantidadeSuitesChange(event) {
        this.quantidadeSuites = event.target.value;
        this.updateFilters('Quantidade de Suítes', this.quantidadeSuites);
    }

    handleTipoUnidadeChange(event) {
        this.tipoUnidade = event.target.value;
        this.updateFilters('Tipo de Unidade', this.tipoUnidade);
    }

    updateFilters(label, value) {
        const existingFilterIndex = this.selectedFilters.findIndex(filter => filter.label === label);
        if (existingFilterIndex >= 0) {
            this.selectedFilters[existingFilterIndex].value = value;
        } else {
            this.selectedFilters = [...this.selectedFilters, { label, value }];
        }
    }

    handleRemoveFilter(event) {
        const labelToRemove = event.target.dataset.label;
        this.selectedFilters = this.selectedFilters.filter(filter => filter.label !== labelToRemove);
    }
}