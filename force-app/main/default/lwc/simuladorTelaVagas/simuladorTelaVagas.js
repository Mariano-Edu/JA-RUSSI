import { LightningElement, track, api } from 'lwc';
import getVagasGaragem from '@salesforce/apex/Product2Controller.getVagasGaragem';
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SimuladorTelaVagas extends NavigationMixin(LightningElement) {
   
    @api empreendimentoId;
    @api paginatedVagas;

    @track statusSelecionado = '';
    @track valorVaga = 0.00;   
    @track formattedValue = 'R$ 0,00';
    @track currentPage = 1;
    @track itemsPerPage = 24; 
    @track selectedVaga = [];
    @track selectedTipoVaga = 'Individual';
    @track vagas = [];
    @track error;
    @track qtdTotalVagas;
    @track qtdVagasSelecionadas = 0;
    @track showModal = false; 
    @track showVagasExtras = false; 
    @track vagasExtras = 0; 
    @track vagaToRemove = null;
    @track isExpanded = false;
    @track showValorField = false;
    @track isVaga = true;
    @track isVagaExtra = false;
    @track ultimaVagaExtraSelecionada;
    @track isButtonDisabled = true;
    @track filtro = true;

    statusOptions = [
        {label: 'Disponível', value: 'Disponível' },
        {label: 'Reservada', value: 'Reservada' },
        {label: 'Bloqueada', value: 'Bloqueada' },
        {label: 'Vendida', value: 'Vendida' },
        {label: 'Permutada', value: 'Permutada'},
        {label: 'Retirada Sócio', value:'Retirada Sócio'}
    ];
    
    connectedCallback() {
        
        this.selectedVagas = [];
        this.loadVagasGaragem();
        this.dispatchQtdTotalVagas();
    
    }
    

    dispatchQtdTotalVagas() {
        const event = new CustomEvent('qtdtotalvagaschange', {
            detail: { 
                qtdTotalVagas: this.qtdTotalVagas,
                vagasExtras: this.vagasExtras,
                
            }
        });
        this.dispatchEvent(event);
    }
    
    loadVagasGaragem() {
        const tipoVagaMap = {
            1: 'Individual',
            2: 'Dupla',
            3: 'Tripla'
        };
    
        const ordemTipoVaga = {
            'Individual': 1,
            'Dupla': 2,
            'Tripla': 3
        };
        
        getVagasGaragem({ idEmpreendimento: this.empreendimentoId })
            .then(result => {
                this.vagas = result.map(vaga => ({
                    id: vaga.Id,
                    nome: vaga.Name.replace('Vaga ', ''),
                    areaVaga: vaga.AreaTotal__c,
                    status: vaga.Status__c, 
                    tipoVaga: tipoVagaMap[vaga.TipoVaga__c] || 'Individual' ,
                    valorVaga: this.valorVaga || 0.00,
                    isExtra: this.qtdVagasSelecionadas >= this.qtdTotalVagas
                    
                }))
                .sort((a, b) => ordemTipoVaga[a.tipoVaga] - ordemTipoVaga[b.tipoVaga]);
                if (result.length > 0) {
                    this.qtdTotalVagas = result[0].Empreendimento__r.VagasUnidade__c;
                }
            })
            .catch(error => {
                this.error = error;
                console.error(error);
            });
    }
    
    
    get tiposVaga() {
        return [...new Set(this.vagas.map(vaga => vaga.tipoVaga))]; 
    }
    
  

    get getStatusOptions() {
        return this.statusOptions;
    }

    get paginatedVagas() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        return this.filteredVagas.slice(start, start + this.itemsPerPage);
    }
    
    

    get totalPages() {
        return Math.ceil(this.filteredVagas.length / this.itemsPerPage);
    }
    
    get isFirstPage() {
        return this.currentPage === 1;
    }
    
    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
    
    get filteredVagas() {
        const filtered = this.vagas
            .filter(vaga => {
                const statusMatch = this.statusSelecionado === '' || vaga.status === this.statusSelecionado;
                return  statusMatch;
            })
            .map(vaga => {
                const styledVaga = {
                    ...vaga,
                    style: this.getStyle(vaga.status),
                    class: this.computeClass(vaga)
                };
                return styledVaga;
            });
    
        return filtered;
    }
    
    handleTipoChange(event) {
        this.selectedTipoVaga = event.target.dataset.tipoVaga;
        this.currentPage = 1;
        this.selectedVaga = null; 
    }

    handleVagaClick(event) {

        if (this.isLoading) return;
        
        const nome = event.currentTarget.dataset.nome;
        const vaga = this.vagas.find(vaga => vaga.nome === nome);

        if (this.selectedTipoVaga && this.selectedTipoVaga !== vaga.tipoVaga) {
            this.showToast('Esta vaga não corresponde ao tipo selecionado.', 'Selecione uma vaga do tipo apropriado.', 'warning');
            return;
        }

    
        if (vaga.status != 'Disponível') {
            this.showToast('Esta vaga não está disponível para seleção no momento.');
            return;
        }
    
        const qtdVaga = this.getQuantidadeVaga(vaga.tipoVaga);
        const index = this.selectedVagas.findIndex(v => v.nome === nome);
    
        if (index > -1) {
            if (this.vagasExtras > 0) {
                this.vagasExtras -= qtdVaga;
            } else {
                this.qtdVagasSelecionadas -= qtdVaga;
            }
            
            this.selectedVagas = this.selectedVagas.filter(v => v.nome !== nome);
        } else if (this.qtdVagasSelecionadas + qtdVaga <= this.qtdTotalVagas) {
            this.qtdVagasSelecionadas += qtdVaga;
            this.selectedVagas.push({ ...vaga, isExtra: false });
        } else {
            this.showModal = true; 
            this.vagaToRemove = vaga;
            this.vagasExtras += qtdVaga;
            const vagaToPush = { 
                ...vaga, 
                isExtra: true, 
                valorVaga: this.valorVaga || 0.00 };
            this.selectedVagas.push(vagaToPush);
            this.ultimaVagaExtraSelecionada = vagaToPush;
        }
    
        if (this.vagasExtras <= 0) this.showVagasExtras = false;
    
        this.dispatchEvent(new CustomEvent('vagaschange', {
            detail: { 
                qtdVagasSelecionadas: this.qtdVagasSelecionadas,
                vagasExtras: this.vagasExtras,
                vaga: this.getSelectedVagas().vagas
            }
            
        }));
    }

    handleAdicionarVagaExtra() {

        this.isExpanded = !this.isExpanded;
        this.isVaga = false;
        this.isVagaExtra = true;
        this.isButtonDisabled = false;
    }
    
   
    
    getQuantidadeVaga(tipoVaga) {
        if(tipoVaga === 'Individual') return 1;
        if(tipoVaga === 'Dupla') return 2;
        if(tipoVaga === 'Tripla') return 3;
        return 1;
    }
    

    handleValorChange(event) {
        this.showValorField = event.target.value == 'sim';
        this.valorVaga = event.target.value;
        this.isButtonDisabled = true;
      
    }
    

    handleYesClick() {
        this.handleValorVaga();
        


    if (this.selectedVagas && this.selectedVagas.length > 0) {
        const ultimaPosicao = this.selectedVagas[this.selectedVagas.length - 1];

        
        for (let i = 0; i < this.selectedVagas.length; i++) {
            if (this.selectedVagas[i].id === ultimaPosicao.id && this.selectedVagas[i].isExtra) {
                this.selectedVagas[i].valorVaga = this.valorVaga;
                break;
            }
        }
    }

        this.valorVaga = 0.00;
        this.showModal = false;
        this.showVagasExtras = true;
        this.vagaToRemove = null;
        this.isExpanded = false;
        this.showValorField = false;
        this.isVagaExtra = false;
        this.isVaga = true;
        this.isButtonDisabled = true;
    }
    
    
    handleNoClick() {
        this.showModal = false;
        this.isVagaExtra = false;
        this.isVaga = true;
        this.isExpanded = false;
        this.showValorField = false;
    
        if (this.vagaToRemove) {
            const index = this.selectedVagas.findIndex(v => v.nome === this.vagaToRemove.nome);
            if (index > -1) {
                let qtdVaga;
                switch (this.vagaToRemove.tipoVaga) {
                    case 'Individual':
                        qtdVaga = 1;
                        break;
                    case 'Dupla':
                        qtdVaga = 2;
                        break;
                    case 'Tripla':
                        qtdVaga = 3;
                        break;
                    default:
                        qtdVaga = 1; 
                }
                this.vagasExtras -= qtdVaga;
                this.selectedVagas.splice(index, 1);
            }
            this.vagaToRemove = null;
        }
    }


    handleChangeStatus(event) {
        this.statusSelecionado = event.target.value;
    }
    
    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
        }
    }
    
    previousPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
        }
    }
    
    getStyle(status) {
        
        const statusColors = {
            'Disponível': '#C7F6D4',
            'Reservada': '#F7CAE4',
            'Bloqueada': '#FF9C9C',
            'Vendida': '#FDFD96',
            'Permutada': '#D3BCF6',
            'Retirada Sócio':'#ADD5FA',
        };
        return `background-color: ${statusColors[status] || '#FFFFFF'};`;
    }
    
    computeClass(vaga) {
        let baseClass = 'vagas-card';
        if (vaga.status === 'Disponível') {
            baseClass += ' available';
        }
        if (this.selectedVagas.some(v => v.nome === vaga.nome)) {
            baseClass += ' selected';
        }
    
        if (this.selectedTipoVaga && this.selectedTipoVaga !== vaga.tipoVaga) {
            baseClass += ' reduced-opacity';
        }
        return baseClass;
    }
    
    get tipoVagaClasses() {
        return this.tiposVaga.map(tipoVaga => {
            let baseClass = 'vagas-card';
            if (this.selectedTipoVaga === tipoVaga) {
                baseClass += ' selected';
            } else {
                baseClass += ' reduced-opacity';
            }
            return { tipoVaga, class: baseClass, upperTipo: tipoVaga };
        });
    }
    

    
    getSelectedVagas() {
        const totalVagas = this.selectedVagas.length;
        const vagasExtras = this.selectedVagas.filter(vaga => vaga.isExtra).length;

        this.vagasSelecionadasInfo = this.selectedVagas.map(vaga => ({
            id: vaga.id,
            nome: vaga.nome,
            areaVaga: vaga.areaVaga,
            tipoVaga: vaga.tipoVaga,
            valorVaga: vaga.valorVaga || 0.00,  
            isExtra: vaga.isExtra
        }));
        
        return {
            totalVagas,
            vagasExtras,
            vagas: this.vagasSelecionadasInfo
        };
    }
    
    
 
    handleVagasChange(event) {
        this.qtdVagasSelecionadas = event.detail.qtdVagasSelecionadas;
        this.vagasExtras = event.detail.vagasExtras;
        this.vagasSelecionadasInfo = event.detail.vagasSelecionadas;
    }
    
    
    
    handleInputValorChange(event) {
        
        let inputValue = parseFloat(event.target.value);
    
        if (inputValue > 0) {
            this.isButtonDisabled = false;
        } else {

            this.isButtonDisabled = true;
            this.valorVaga = 0;
        }

        this.valorVaga = inputValue;
            
    }
    
    handleChange(event) {
        this.valor =  event.target.value;
    }
    
    handleValorVaga() {
        const vagaExtra = this.selectedVagas.find(vaga => vaga.id === this.ultimaVagaExtraSelecionada.id);
    
        if (!vagaExtra) return;
    
        const valorVagaEvent = new CustomEvent('valorchange', {
            detail: {
                valorVaga: this.valorVaga,
                idVaga: vagaExtra.id
            }
        });
    
        this.dispatchEvent(valorVagaEvent);
    }

    getVagaId() {
        return this.vaga ? this.vaga.Id : null;
    }


    handleVagaSelecionada(vaga) {
        this.selectedVagas.push(vaga);
    }

    handleVagaRemovida(vagaId) {
        this.selectedVagas = this.selectedVagas.filter(vaga => vaga.id !== vagaId);
    }

    showToast(title, message, variant = 'error') {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleDetalhes(event) {
        event.stopPropagation();
        
        const vagaId = event.currentTarget.dataset.id;
        if (vagaId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: vagaId,
                    objectApiName: 'Product2', 
                    actionName: 'view'
                }
            });
        } else {
            console.error('Vaga Id is not defined');
        }
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