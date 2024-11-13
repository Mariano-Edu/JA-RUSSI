import { LightningElement, track, api , wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import buscarStatusUnidades from '@salesforce/apex/EspelhoVendasController.buscarStatusUnidades';
import buscarTiposUnidades from '@salesforce/apex/EspelhoVendasController.buscarTiposUnidades';

export default class EspelhoDeVendasFiltro extends LightningElement {
    @api opportunity;
    @api empreendimento;
    @track bloco = '';
    @track andar = '';
    @track status = '';
    @track finalUnidade = '';
    @track valor = 0;
    @track minValue = 0;
    @track maxValue = 50000000;
    @track stepValue = 1000;
    @track metragem = 50;
    @track metragemPills = [];
    @track valorPills = [];
    @track showSuggestions = false;
    @track empreendimentoOptions = [];
    @track selectedEmpreendimento = '';
    @api tabelaOptions;
    @api blocoOptions;
    @track andarOptions = [];
    @track selectedBloco = '';
    @track previousFilteredApartments = []; 
    @track empreendimentoPills = [];
    @track valorPills = []
    @track blocoPills = [];
    @track tipoUnidade = '';
    @track andarPills = [];
    @track finalUnidadePills = [];
    @track quantidadeQuartosPills = []
    @track tipoUnidadePills = [];
    @track quantidadeSuitesPills = []
    @track quantidadeSuites = '';
    @track andares = [];
    @track mostrarFiltrosExtras = false;    
    @track typeOptions = [];
    @track selectedType = [];
    @api cotacaoId;

    @track statusOptions = [];

    @track filtroState = false;
    
    @track blocoSelecionado;
    @track tabelaSelecionada;
    @track andaresSelecionados = [];
    @track apartamentosBloco = [];
    @track statusSelecionados = [];
    @track tipoUnidadeSelecionados = [];

    @track valorMinimo;
    @track valorMaximo;

    @track metragemMinima;
    @track metragemMaxima;

    @api apartments;
    inicializou = false;
    
    @wire(buscarStatusUnidades)
    wiredStatuses({ error, data }) {
        if(data) {
            this.statusOptions = data.map(status => ({ label: status, value: status }));
        } else if (error) {
            console.error('Error fetching unit statuses', error);
        }
    }

    @wire(buscarTiposUnidades)
    wiredTypes({ error, data }) {
        if(data) {
            this.typeOptions = data.map(type => ({ label: type.Name, value: type.Id }));
        } else if (error) {
            console.error('Error fetching unit types', error);
        }
    }

    @track FilteredApartments;

    get getTabelaDisabled() {
        return !(this.getTabelaOptions && this.getTabelaOptions.length > 0);
    }

    get filteredApartments() {
        return this.filteredApartments;
    }

    @api
    get getTabelaOptions() {
        return this.tabelaOptions;
    }

    get getTabelaPlaceholder() {
        return this.getTabelaDisabled ? 'Nenhuma tabela encontrada' : 'Selecione uma tabela';
    }
    
    get getOpportunity() {
        return this.opportunity;
    }

    get getTabelaSelecionada() {
        return this.tabelaSelecionada;
    }

    get getBlocoOptions() {
        return this.blocoOptions;
    }

    get getBlocoSelecionado() {
        return this.blocoSelecionado;
    }

    get getAndaresSelecionados() {
        return this.andaresSelecionados;
    }

    get getStatusSelecionados() {
        return this.statusSelecionados
    }

    get getTipoUnidadeSelecionados() {
        return this.tipoUnidadeSelecionados;
    }

    get getEmpreendimento() {
        return this.empreendimento;
    }

    get isBlocoNotSelecionado() {
        return (this.getBlocoSelecionado === '' || this.getBlocoSelecionado ? false : true)
    }

    get getFinalUnidade() {
        return this.finalUnidade
    }

    get getBlocoHabilitado() {
        return (this.getTabelaSelecionada && this.empreendimento) || (!this.isInCotacao && this.empreendimento);
    }

    get getMetragemMinima() {
        return this.metragemMinima !== 0 ? this.metragemMinima : null;
    }
    get getMetragemMaxima() {
        return this.metragemMaxima !== 0 ? this.metragemMaxima : null;
    }

    get getValorMinimo() {
        return this.valorMinimo !== 0 ? this.valorMinimo : null;
    }
    get getValorMaximo() {
        return this.valorMaximo !== 0 ? this.valorMaximo : null;
    }   

    get isInCotacao() { 
        return this.cotacaoId !== undefined;
    }

    get getLimparFiltroDesabilitado() {

        return !(
            this.andaresSelecionados.length > 0 || 
            this.statusSelecionados.length > 0 || 
            this.finalUnidadePills.length > 0 ||
            this.quantidadeQuartosPills.length > 0 ||
            this.quantidadeSuitesPills.length > 0 ||
            this.tipoUnidadePills.length > 0 ||
            this.valorMinimo ||
            this.valorMaximo ||
            this.metragemMinima ||
            this.metragemMaxima
        );
    }

    renderedCallback() {
        if(this.inicializou) return;
        
        const pickListStatus = this.template.querySelector('[role="cm-picklist-status"]');

        if(!pickListStatus.getSelectedList()) pickListStatus.setOptions(this.statusOptions);

        
        if(this.mostrarFiltrosExtras) {
            const picklistTipo = this.template.querySelector('[role="cm-picklist-tipoUnidade"]');

            if (picklistTipo && !picklistTipo.getSelectedList()) {
                picklistTipo.setOptions(this.typeOptions);
                picklistTipo.setSelectedList(null);
            }
        }

    }

    handleEmpreendimento(event) {
        const empreendimentoId = event.detail.recordId;
        
        this.limparFiltros();
        this.blocoSelecionado = null;
        
        this.empreendimento = empreendimentoId

        if(empreendimentoId === null) {
            this.blocoOptions = [];
            this.dispatchEvent(new CustomEvent('selectempreendimento', { detail: { idEmpreendimento: null } }));
            return;
        }
        
        this.dispatchEvent(new CustomEvent('selectempreendimento', { detail: { idEmpreendimento: this.empreendimento } }));
    }

    recarregarEspelho() {
        this.blocoSelecionado = null;
        this.tabelaSelecionada = null;
        this.limparFiltros();
        this.dispatchEvent(new CustomEvent('recarregarespelho'));
    }

    limparFiltros() {
        const campos = this.template.querySelectorAll('[role^="cm-picklist"], [data-field]');

        campos.forEach(campo => {
            if(campo.getAttribute('role')) {

                campo.clearSelectedList();

                if(campo.getAttribute('role' === 'cm-picklist-andar')) {
                    campo.setOptions([]);
                }

            } else if(campo.getAttribute('data-field')) {
                campo.value = null;
            }
        });

        this.finalUnidadePills = [];
        this.quantidadeSuites = null;

        this.finalUnidade = null;


        this.quantidadeQuartosPills = [];
        this.quantidadeSuitesPills = [];
        this.andaresSelecionados = [];
        this.statusSelecionados = [];
        this.valorMinimo = null;
        this.valorMaximo = null;
        this.metragemMinima = null;
        this.metragemMaxima = null;
    }
    
    buscarAndares() {
        if (this.apartamentosBloco.length <= 0) return;

        let andarValues = [];
        this.apartamentosBloco.forEach(apartamento => {
            if(!andarValues.includes(apartamento.Andar__c)) {
                andarValues.push(apartamento.Andar__c);
            }
        })

        andarValues.sort((a, b) => a - b);

        this.andarOptions = andarValues.map(andar => { return {"label": "Andar "+ andar, "value": andar } });
        this.template.querySelector('[role="cm-picklist-andar"]').setOptions(this.andarOptions);
    }

    handleChangeBloco(event) {
        this.limparFiltros();
        
        this.blocoSelecionado = event.detail.value;

        this.apartamentosBloco = this.apartments
            .filter(apartamento => apartamento.Bloco__c === this.blocoSelecionado);

        this.buscarAndares();
        this.filterSuggestions();
    }

    handleChangeTabela(event) {
        this.tabelaSelecionada = event.detail.value;

        this.dispatchEvent(new CustomEvent('selecionartabela', { detail: { idTabela: this.tabelaSelecionada, tabelaOptions: this.tabelaOptions } }));
    }

    handleAndarChange(event) {
        const selectedValues = event.detail.selectedValues;
        
        if (!selectedValues || selectedValues.trim() === '') {
            this.andaresSelecionados = [];
            this.filterSuggestions();
            return;
        } else {
            this.andaresSelecionados = selectedValues.split(';').map(Number);
            this.filterSuggestions();
        }
        
        //tem que ter essa porqueira pra n entrar em um loop :(
    }

    handleStatusChange(event) {
        const selectedValues = event.detail.selectedValues;

        if (!selectedValues || selectedValues.trim() === '') {
            this.statusSelecionados = [];
        } else {
            this.statusSelecionados = selectedValues.split(';');
        }

        this.filterSuggestions();
    }

    handleTipoUnidadeChange(event) {
        const selectedValues = event.detail.selectedValues;
        
        if (!selectedValues || selectedValues.trim() === '') {
            this.tipoUnidadeSelecionados = []
            this.filterSuggestions();
        }
        else {
            this.tipoUnidadeSelecionados = selectedValues.split(';');
            this.filterSuggestions();
        }

    }


    removerTipoUnidade(event) {
        const labelToRemove = event.currentTarget.dataset.label;
        this.tipoUnidadePills = this.tipoUnidadePills.filter(pill => pill.label !== labelToRemove);
        this.filterSuggestions();
    }

    removerQuantidadeSuites(event) {
        const labelToRemove = event.currentTarget.dataset.label;
        this.quantidadeSuitesPills = this.quantidadeSuitesPills.filter(pill => pill.label !== labelToRemove);
        this.filterSuggestions();
    }

    handleKeydown(event) {
        if (event.key === 'Enter') {
            this.adicionarMetragemPill();
        }
    }

    adicionarMetragemPill() {
        if (!this.metragemPills.some(pill => pill.label === this.metragem)) {
            this.metragemPills = [...this.metragemPills, { label: this.metragem }];
        }

        this.filterSuggestions();
    }

    removerQuantidadeQuartos(event) {
        const labelToRemove = event.currentTarget.dataset.label;
       
        if (labelToRemove) {
            this.quantidadeQuartosPills = this.quantidadeQuartosPills.filter(pill => pill.label !== labelToRemove);
            this.filterSuggestions();
        } else {
            console.error('No label found for removal.');
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field; 
        const valor = Number(event.target.value); 
 
        if (!isNaN(valor)) this[field] = valor;
        else this[field] = null;
    
        this.filterSuggestions();
    }

    handleInputQuantidadeSuites(event) {
        this.quantidadeSuites = event.target.value;
        this.filterSuggestions();
    }

    handleInputMetragem(event) {
        const input = event.target;

        const campoInvalido = this.campoDeFaixaInvalido(input, { superior: 'metragemMaxima', inferior: 'metragemMinima' });

        input.setCustomValidity(campoInvalido ? 'O valor de metragem mínima não pode ser maior que o valor de metragem máxima' : '');

        input.reportValidity();
       
        if(campoInvalido && this.valorMinimo > this.valorMaximo) {
            this.dispatchEvent(new CustomEvent('filterupdate', { detail: [] }));
            return;
        }

        this.handleInputChange(event);
    }

    handleInputValor(event) {
        const input = event.target;

        const campoInvalido = this.campoDeFaixaInvalido(input, { superior: 'valorMaximo', inferior: 'valorMinimo' });

        input.setCustomValidity(campoInvalido ? 'O valor mínimo não pode ser maior que o valor máximo' : '');
        input.reportValidity();
        
        if(campoInvalido && this.metragemMinima > this.metragemMaxima) {
            this.dispatchEvent(new CustomEvent('filterupdate', { detail: [] }));
            return;
        }

        this.handleInputChange(event);
    }

    campoDeFaixaInvalido(input, fieldsIntervalo) {
        const delimitadorAlterado = Number(input.value);
        const isSuperiorChanging = input.dataset.field === fieldsIntervalo.superior;
        const delimitadorInalterado = this[isSuperiorChanging ? fieldsIntervalo.inferior : fieldsIntervalo.superior];

        if(!delimitadorInalterado || !delimitadorAlterado) return false;

        const [extremoInferior, extremoSuperior] = isSuperiorChanging
                ? [delimitadorInalterado, delimitadorAlterado]
                : [delimitadorAlterado, delimitadorInalterado];

        return extremoInferior > extremoSuperior;
    }

    formatarParaRealBrasileiro(event) {
        const valor = parseFloat(event.target.value.replace(/[^\d.]/g, ''));
    
        if(isNaN(valor)) {
            this.valor = '';
            return;
        }
    
        this.valor = valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    }

    handleKeyup(event) {
        if(event.key !== 'Enter') return;

        const value = event.target.value;
        
        if(!value) return;
        
        if(value.includes(' ')) {
            this.showToast('Erro', 'Não pode conter espaços', 'error');
            return;
        }
        
        const fieldPills = this[`${event.target.dataset.field}Pills`];

        if(fieldPills.length > 4) {
            this.showToast('Erro', 'O máximo de pílulas permitidas são 5', 'error');
            return;
        }

        if (fieldPills.some(pill => pill.label.toLowerCase() === value.toLowerCase())) {
            this.showToast('Aviso', `O valor "${value}" já existe na lista de filtros.`, 'warning');
            return;
        }

        fieldPills.push({ label: value, value: value });
        this.filterSuggestions();
    }
    
    handleRemove(event) {
        const fieldName = event.target.dataset.field;
        const pillLabel = event.target.label;
    
        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);
        this.filterSuggestions();
    }

    filterSuggestions() {
        const finalUnidadeSelecionados = this.finalUnidadePills.map(item => Number(item.label));

        const quantidadeQuartosSelecionados = this.quantidadeQuartosPills.map(item => Number(item.label));

        const filtroValorMinimo = this.valorMinimo ? this.valorMinimo : Number.NEGATIVE_INFINITY;
        const filtroValorMaximo = this.valorMaximo ? this.valorMaximo : Number.POSITIVE_INFINITY;

        const filtroMetragemMinima = this.metragemMinima ? this.metragemMinima : Number.NEGATIVE_INFINITY;
        const filtroMetragemMaxima = this.metragemMaxima ? this.metragemMaxima : Number.POSITIVE_INFINITY;

        const quantidadeSuitesSelecionados = this.quantidadeSuitesPills.map(item => Number(item.label));


        const apartamentosFiltrados = this.apartments
            .filter(apartamento =>
                finalUnidadeSelecionados.length === 0 ||
                    finalUnidadeSelecionados.includes(Number(apartamento.Name.toString().slice(-3)))
            )
            .filter(apartamento => !this.getBlocoSelecionado || apartamento.Bloco__c === this.getBlocoSelecionado)
            .filter(apartamento => 
                this.getAndaresSelecionados.length === 0 ||
                    this.getAndaresSelecionados.includes(apartamento.Andar__c)
            )
            .filter(apartamento => 
                this.getStatusSelecionados.length === 0 ||
                    this.getStatusSelecionados.includes(apartamento.Status__c)
            )
            .filter(apartamento => 
                quantidadeQuartosSelecionados.length === 0 ||
                    quantidadeQuartosSelecionados.includes(apartamento.NumeroQuartos__c)
            )
            .filter(apartamento =>
                apartamento.ValorDaUnidade__c >= filtroValorMinimo &&
                    apartamento.ValorDaUnidade__c <= filtroValorMaximo
            )
            .filter(apartamento => 
                apartamento.MetragemDaUnidadeM__c >= filtroMetragemMinima &&
                    apartamento.MetragemDaUnidadeM__c <= filtroMetragemMaxima
            )
            .filter(apartamento =>
                quantidadeSuitesSelecionados.length === 0 || 
                    quantidadeSuitesSelecionados.includes(apartamento.NumeroDeSuites__c)

            )
            .filter(apartamento => 
                this.tipoUnidadeSelecionados.length === 0 ||
                    this.tipoUnidadeSelecionados.includes(apartamento.RecordTypeId)
            );
        
        this.dispatchEvent(new CustomEvent('filterupdate', { detail: apartamentosFiltrados }));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode: 'dismissable' }));
    }
    
    remover(event) {
        const pillLabel = event.currentTarget.dataset.label;  
        const fieldName = 'andar';
    
        if (pillLabel === undefined) {
            console.error('Label da pílula é undefined');
            return;
        }

        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);
        this.filterSuggestions();
    }
    
    get valorFormatado() {
        const formatador = new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
        });
        return formatador.format(this.valor);
    }
   
    removerBloco(event) {
        const labelToRemove = event.currentTarget.dataset.label;
        this.blocoPills = this.blocoPills.filter(pill => pill.label !== labelToRemove);
        this.filterSuggestions();
    }

    removerFinalUnidade(event) {
        const pillLabel = event.currentTarget.dataset.label; 
        const fieldName = 'finalUnidade';  

        if (pillLabel === undefined) {
            console.error('Label da pílula é undefined');
            return;
        }
        
        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);       
        this.filterSuggestions();
    }
    
    abrirFiltrosExtras() {
        this.filtroState = !this.filtroState;
        this.mostrarFiltrosExtras = !this.mostrarFiltrosExtras;
    }

    selecionarUnidade(event) {
        this.dispatchEvent(new CustomEvent('selecionarunidade', {
            detail: {id: event.detail}
        }));
    }
}