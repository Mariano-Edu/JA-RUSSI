import { LightningElement, wire, track , api } from 'lwc';
import retornarUnidadesDisponiveis from '@salesforce/apex/EspelhoVendasController.retornarUnidadesDisponiveis';
import { NavigationMixin } from 'lightning/navigation';

const colorMap = {
    'Disponível': '#C7F6D4',
    'Reservada': '#F7CAE4',
    'Bloqueada': '#FF9C9C',
    'Vendida': '#FDFD96',
    'Permutada': '#D3BCF6',
    'Retirada Sócio':'#ADD5FA',
    'Em Negociação':'#FF9D3D'
};

export default class FloorApartmentComponent extends NavigationMixin(LightningElement) {
    @track currentPage = 0;
    @track totalPages = 0;
    itemsPerPage = 6;   
    maxFloorsPerPage = 4;
    @track floors = [];
    @api apartments;
    @track visibleFloors = [];
    @track empreendimentosBancoDados = [];
    @api filtrados;
    @track configuracoesCores = [];
    @track cores = [];
    @track corDisponivel = '';
    @track corReservado = '';
    @track corVendida = '';
    @track idUnidadeSelecionada;
    @track qtdTotalVagas = 0;
    @api entradaPrecosMap;

    _empreendimentoSelecionado;
    _filteredApartments

    @api
    set empreendimentoSelecionado(value) {
        this.floors = null;
        this.currentPage = 0;
        this.visibleFloors = null;
        
        this._empreendimentoSelecionado = value;
        this.buscarUnidadesDisponiveis(this.empreendimentoSelecionado); 
    }

    get empreendimentoSelecionado() {
        return this._empreendimentoSelecionado;
    }

    get getVisibleFloors() {
        return this.visibleFloors;
    }

    @api getEntradaPrecosMap() {
        return this.entradaPrecosMap;
    }

    get isInCotacao() {
        return this.entradaPrecosMap !== undefined;
    }
    
    @api
    set filteredApartments(value){
        this._filteredApartments = value;
        this.resetComponent(this.filteredApartments)
        this.updateQtdVagas(this.filteredApartments);
    }

    get filteredApartments() {
        return this._filteredApartments;
    }
      
    @api
    updateFilteredApartments(filteredApartments) {
        this.filteredApartments = filteredApartments;

        if (!filteredApartments || filteredApartments.length === 0) {
            this.resetComponent(this.empreendimentoSelecionado);
        } else {
            this.atualizarMatriz(filteredApartments);
        }
    }


    atualizarMatriz(filteredApartments) {
        const allFloors = [...this.visibleFloors];
        
        this.visibleFloors = [];
        const floorMap = new Map();
    
        filteredApartments.forEach(unit => {

            const floorId = unit.andar;
    
            if (!floorMap.has(floorId)) {
                floorMap.set(floorId, {
                    id: 'floor-' + floorId,
                    andar: floorId,
                    apartments: []
                });
            }
    
            // Adiciona apartamentos ao andar correspondente
            let colorStyle = unit.color || ''; // Verifica a cor
            floorMap.get(floorId).apartments.push({
                id: unit.id,
                price: unit.price,
                valor: unit.valor,
                status: unit.status,
                rooms: unit.rooms,
                color: colorStyle,
                preco: unit.preco,
                quantidadeSuites: unit.quantidadeSuites,
                numeroQuartos: unit.numeroQuartos,
                metrosQuadrados: unit.metrosQuadrados,
                name: unit.name,
                Vagas: unit.qtdVagas,
                empreendimento: unit.empreendimento,
                empreendimentoId: unit.Empreendimento__c ? unit.Empreendimento__c : 'Desconhecido' ,
                andar: unit.andar,
                tipoUnidade: unit.tipoUnidade,
                selected: unit.selected || false
            });
        });
    
            const floors = [];
        floorMap.forEach(floor => {
            const apartmentChunks = this.chunkArray(floor.apartments, this.itemsPerPage);
            apartmentChunks.forEach((chunk, index) => {
                floors.push({
                    id: floor.id + '-' + index,
                    andar: floor.andar,
                    apartments: chunk
                });
            });
        });
    
        // Ordena os andares por número
        floors.sort((a, b) => parseInt(a.andar) - parseInt(b.andar));
    
        // Atualiza visibleFloors com os andares filtrados

        this.visibleFloors = floors;
        this.totalPages = Math.ceil(floors.length / this.itemsPerPage); // Calcula o total de páginas
    }
    
    resetComponent(filteredApartments) {
        this.currentPage = 1;
        this.loadUnidadesDisponiveis(filteredApartments);
    }

    updateQtdVagas(floors) {
        const mapTipoVaga = {
            'Individual': 1,
            'Dupla': 2,
            'Tripla': 3
        };
        
        let qtdVagas = 0;
        floors.forEach(floor => {
            if (floor.TipoVaga__c != null) qtdVagas += mapTipoVaga[floor.TipoVaga__c];
        });

        this.qtdTotalVagas = qtdVagas;
    }
    
    buscarUnidadesDisponiveis(idEmpreendimento){
        if(!idEmpreendimento) return;

        retornarUnidadesDisponiveis({ idEmpreendimento: idEmpreendimento })
            .then(data => {this.dispatchEvent(new CustomEvent('changeapartments', { detail: data }))})
            .catch(error => console.error('Erro ao carregar unidades disponíveis:', error));
    }

    loadUnidadesDisponiveis(filteredApartments) {
        if(!filteredApartments) {
            this.floors = null;
            this.currentPage = 0;
        }

        this.floors = this.structureFloors(filteredApartments);
        this.totalPages = Math.ceil(this.floors.length / this.maxFloorsPerPage);
        this.updateVisibleFloors();
    }
    
    updateVisibleFloors() {
        const startIdx = (this.currentPage - 1) * this.maxFloorsPerPage;
        const endIdx = startIdx + this.maxFloorsPerPage;
        this.visibleFloors = this.floors.slice(startIdx, endIdx);
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateVisibleFloors();
            this.pintarCores()
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateVisibleFloors();
            this.pintarCores()
        }
    }

    truncateName(name, maxLength = 20) {
        return name.length > maxLength ? name.substring(0, maxLength) + '...' : name;
    }

    structureFloors(units) {
        let floors = [];
        let floorMap = new Map();
    
        units.forEach(unit => {
            let floorId = unit.Andar__c;
            if (!floorMap.has(floorId)) {
                floorMap.set(floorId, {
                    id: 'floor-' + floorId,
                    andar: floorId,
                    apartments: []
                });
            }

            let lastTwoDigits = this.pegarUltimosDoisNumeros(unit.NumeroDaUnidade__c);
    
            floorMap.get(floorId).apartments.push({
                id: unit.Id,
                preco: this.entradaPrecosMap ? this.entradaPrecosMap[unit.Id]?.ValorVenda__c : 0,
                // preco: unit.ValorDaUnidade__c,
                metrosQuadrados: unit.MetragemDaUnidadeM__c,
                qtdVagas: unit.QuantidadeVagas__c,
                area: unit.Area__c,
                empreendimento: unit.Empreendimento__r ? unit.Empreendimento__r.Name : 'Desconhecido',
                empreendimentoId: unit.Empreendimento__c ? unit.Empreendimento__c : 'Desconhecido' ,
                diasVencimento: unit.Empreendimento__r ? unit.Empreendimento__r.DiasDeVencimentoDaParcela__c : '',
                bloco: unit.Bloco__r ? unit.Bloco__r.Name : 'Desconhecido',
                status: unit.Status__c,
                numeroQuartos: unit.NumeroQuartos__c,
                color: `background-color: ${colorMap[unit.Status__c] || '#EDEDED'};`,
                numeroUnidade: lastTwoDigits,  // Use os últimos dois dígitos
                tipo: unit.Tipo__c,
                quantidadeSuites: unit.NumeroQuartos__c,
                name: this.truncateName(unit.Name),
                andar: unit.Andar__c,
                tipoUnidade: unit.RecordType ? unit.RecordType.Name : 'Desconhecido',
                selected: false
            });
        });
    
        // Passo 2: Agrupar por Andares e Chunking
        floorMap.forEach(floor => {
            // Ordenar apartamentos dentro de cada andar pelo número completo da unidade
            floor.apartments.sort((a, b) => {
                return parseInt(a.numeroUnidade) - parseInt(b.numeroUnidade);
            });
    
            // Dividir em grupos de 6 apartamentos
            const apartmentChunks = this.chunkArray(floor.apartments, 6);
    
            apartmentChunks.forEach((chunk, index) => {
                floors.push({
                    id: floor.id + '-' + index,
                    andar: floor.andar,
                    apartments: chunk
                });
            });
        });
    
        // Ordenar por Andar
        floors.sort((a, b) => {
            return parseInt(a.andar) - parseInt(b.andar);
        });
    
        // Atualizar visibleFloors com todos os andares estruturados
        this.visibleFloors = floors;
        
        // Chamar pintarCores para garantir que todas as cores sejam aplicadas
        // this.pintarCores();
    
        const apartmentsEvent = new CustomEvent('apartmentschange', {
            detail: floors
        });
        this.dispatchEvent(apartmentsEvent);
        return floors;
    }
    
    pintarCores() {
        if (!this.visibleFloors) {
            console.error('this.visibleFloors não está definido');
            return;
        }
        
        this.visibleFloors.forEach(floor => {
            floor.apartments.forEach(apartment => {
                apartment.color = `background-color: ${colorMap[unit.Status__c] || '#EDEDED'};`;
            });
        });

        const apartmentsEvent = new CustomEvent('apartmentschange', {
            detail: this.visibleFloors
        });

        this.dispatchEvent(apartmentsEvent);
    }
   
    pegarUltimosDoisNumeros(numero) {
        numero = String(numero);

        if (numero.length >= 2) return numero.slice(-2);
        return '';
    }
    
    chunkArray(array, chunkSize) {
        const results = [];
        for (let i = 0; i < array.length; i += chunkSize) {
            results.push(array.slice(i, i + chunkSize));
        }
        return results;
    }
    

    navigateToApartment(event) {
        const apartmentId = event.currentTarget.dataset.id;
        event.target.style.borderBottom = '2px solid black';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: apartmentId,
                objectApiName: 'Apartment__c',
                actionName: 'view'
            }
        });
    }

    showUnderline(event) {
        event.target.style.borderBottom = '1px solid black';
        event.target.style.display = 'inline-block';
        event.target.style.cursor = 'zoom-in';
    }
    
    hideUnderline(event) {
        event.target.style.borderBottom = 'none';
    }
    
    handleSelecionarUnidade(event) {
        let target = event.currentTarget;
        let unidadeSelecionada;
        let unidadeAnterior;

        this.visibleFloors.forEach(visibleFloor =>{
                if(unidadeSelecionada){return;}
                unidadeSelecionada = visibleFloor.apartments.find(unidade => unidade.id === target.dataset.id)
        })

        if(this.idUnidadeSelecionada) {
            this.visibleFloors.forEach(visibleFloor =>{
                if(unidadeAnterior){ return; }
                 unidadeAnterior = visibleFloor.apartments.find(unidade => unidade.id === this.idUnidadeSelecionada)
            })

            if(unidadeAnterior) {
                unidadeAnterior.selected = false;
            }
        }   

        unidadeSelecionada.selected = true;
        this.template.querySelectorAll('c-unidade-card').forEach(card => {
            card.setCardSelecionado(false);
        });
        
        target.setCardSelecionado(true);
        this.idUnidadeSelecionada = unidadeSelecionada.id;
  
        this.dispatchEvent(new CustomEvent('selecionarunidade', {
            detail: {produtoSelecionado: unidadeSelecionada}
        }));
    }
}