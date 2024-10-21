import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import buscarProdutoPorId from '@salesforce/apex/SimuladorVendasController.buscarProdutoPorId';
import buscarEntradaTabelaPrecoPorIdDeProduto from '@salesforce/apex/SimuladorVendasController.buscarEntradaTabelaPrecoPorIdDeProduto';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import obterSeriesPorIdTabela from '@salesforce/apex/SimuladorTelaNegociacaoController.obterSeriesPorIdTabela';

import calcularTotalVPLTabela from '@salesforce/apex/CotacaoController.calcularTotalVPLTabela'
import calcularTotalVPLProposta from '@salesforce/apex/CotacaoController.calcularTotalVPLProposta'
import criarTabelaDaSimulacao from '@salesforce/apex/CotacaoController.criarTabelaDaSimulacao'

import obterTabelasPorIdEmpreendimento from '@salesforce/apex/SimuladorTelaNegociacaoController.obterTabelasPorIdEmpreendimento';
import {calcularInicioPagamentoSeriePagamentos, calcularPorcParcelaSeriePagamento, calcularValorParcelaSeriePagamento, calcularValorTotalSeriePagamento, calcularDiferencaMeses} from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';

const tabelaVendasColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c', type: 'number' },
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c', type: 'number' },
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency' }, //não achei
    { label: 'Valor Total', fieldName: 'ValorTotal', type: 'currency' },//não achei
    { label: '% parcela', fieldName: 'porcentagemParcela', type: 'number' }, // não achei
    { label: '% total', fieldName: 'ValorTotal__c', type: 'number' },
    { label: 'Após habite-se?', fieldName: 'AposHabiteSe__c', type: 'boolean' }
];

const periodicidades = [
        {tipoCondicao: 'Ato', periodicidade: 1}, 
        {tipoCondicao: 'Mensais', periodicidade: 1}, 
        {tipoCondicao: 'Sinal', periodicidade: 1}, 
        {tipoCondicao: 'Única', periodicidade: 1}, 
        {tipoCondicao: 'Financiamento', periodicidade: 1}, 
        {tipoCondicao: 'Periódica', periodicidade: 1}, 
        {tipoCondicao: 'Bimestral', periodicidade: 2}, 
        {tipoCondicao: 'Trimestral', periodicidade: 3}, 
        {tipoCondicao: 'Semestrais', periodicidade: 6}, 
        {tipoCondicao: 'Anuais', periodicidade: 12}
    ];

export default class SimuladorDeVendas extends NavigationMixin(LightningElement) {
    
    tabelaVendasColunas = tabelaVendasColunas;
    periodicidades = periodicidades;

    @track currentStep = 0;
    
    @track produtoSelecionado;
    @track idProdutoSelecionado;

    @track tabelasVendas;
    @track tabelaVendasVingenteValue;

    @track ultimaTabelaSelecionada;
    @track tabelaVendaSelecionada;
    @track tabelaVendasInfoComplementares; 
    @track seriesVendaTabelaSelecionada;

    @track valorNominalTabelaSelecionada = 0;
    @track valorVplTabelaSelecionada = 0;

    @track propostasCliente = [];
    @track valorNominalProposta = 0;
    @track valorVplProposta = 0;

    @api recordId;
    
    @track cotacaoRecord;
    propostaTravada = false;

    stepValues = [
        'espelho', 'unidade','vaga', 'negociacao', 'extrato'
    ];

    get currentStepValue() {
        return this.stepValues[this.currentStep];
    }

    get etapaEspelho() {
        return this.currentStepValue === 'espelho';
    }

    get etapaUnidade() {
        return this.currentStepValue === 'unidade';
    }
    get etapaVaga() {
        return this.currentStepValue === 'vaga';
    }

    get etapaNegociacao() {
        return this.currentStepValue === 'negociacao';
    }

    get isFirstStep() {
        return this.currentStep === 0;
    }

    get isLastStep() {
        return this.currentStep === 4;
    }


    get isIsProdutoSelecionado(){
        return this.produtoSelecionado ? true : false;
    }

    get getProdutoSelecionado(){
        return {
                'idUnidade': this.produtoSelecionado.Id,
                'idEmpreendimento': this.produtoSelecionado.Empreendimento__c,
                'DiasDeVencimentoDaParcela': this.produtoSelecionado.diasVencimento ? this.produtoSelecionado.diasVencimento : ""
                };
    }

    
    get getIdEmpreendimento(){
        return this.produtoSelecionado.empreendimentoId;
    }

    get getTabelasVendas(){
        return this.tabelasVendas;
    }

    get getTabelaVendasSelecionadaId(){
        return this.tabelaVendaSelecionada.Id
    }

    get getValorNominalProposta(){
        return this.valorNominalProposta;
    }

    get getValorVplProposta(){
        return this.valorVplProposta;
    }

    
    get getValoresMatriz(){
        return {
                nominalProposta: this.valorNominalProposta,
                valorVplProposta: this.valorVplProposta, 
                nominalTabela: this.valorNominalTabelaSelecionada,
                valorVplTabela: this.valorVplTabelaSelecionada
               }
    }

    get getCotacaoName(){
        return this.cotacaoRecord.fields.Name.value
    }

    get getCotacaoId(){
        return this.recordId;
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Quote.Name'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.cotacaoRecord = data;
            
        } else if (error) {
            console.log(error)
            this.record = undefined;
        }
    }




    doPrevStep(){
        if(this.isFirstStep) {return};
        switch (this.currentStep){
            case 0:
                this.currentStep--;
            case 1:
                this.limparDadosSimulacao();
                this.currentStep--;
            break;
            case 2:
                this.currentStep--;
            break;
            case 3:
                this.currentStep--;
            break;
            case 4:
                this.propostaTravada = true;
                this.currentStep--;
            break;

        }
    }

    showNotification(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
          title: titulo,
          message: mensagem,
          variant: variante,
        });
        this.dispatchEvent(evt);
      }

    
    doNextstep(){
        if(this.isLastStep) {return};
        switch (this.currentStep){
            case 0:
            if(!this.isIsProdutoSelecionado){
                this.showNotification("Unidade não selecionada", "Selecione uma unidade para prosseguir", "error")
                return;
            }

            this.obterTabelasPorIdEmpreendimento();
            break;
            case 1:
                this.currentStep++
            break;
            case 2:
                if(!this.tabelaVendaSelecionada){
                    this.showNotification("Tabela de vendas não selecionada", "Selecione uma tabela de vendas para prosseguir", "error")
                    return;
                }
                this.currentStep++;
            break;
            case 3:                
                this.currentStep++;
            break;
            case 4:
                this.currentStep++;
            break;

        }
        
    }

    handleChooseUnidade (event){
        let produtoSelecionado = event.detail.produtoSelecionado;
        this.produtoSelecionado = {...produtoSelecionado}
    }
    
    obterTabelasPorIdEmpreendimento(){
        obterTabelasPorIdEmpreendimento({idEmpreendimento: this.getIdEmpreendimento})
            .then(result => {
                let tabelaVendas =[]


                result.forEach(element => {
                    tabelaVendas.push(element);
                });
                
                this.tabelasVendas = tabelaVendas;

                let tabelaVendaVingenteObject = this.buscarTabelaVingente();

                if(!tabelaVendaVingenteObject){this.currentStep++; return;};
                
                this.calcularTotalVPLTabela(tabelaVendaVingenteObject)

                
                
                this.currentStep++;
            })
            .catch(error => {
                console.log(error);
            })
    }


     buscarTabelaVingente(){
        let idTabelaVendasVingente;

        this.tabelasVendas.forEach(tabela=>{
            if(tabela.Situacao__c == 'Em vigor' && tabela.Ativa__c){
                idTabelaVendasVingente = tabela.Id;
            }
        })

        if (!idTabelaVendasVingente){return;}
        return this.tabelasVendas.find(tabela => tabela.Id === idTabelaVendasVingente);
    }

    calcularTotalVPLTabela(tabelaSelecionadaObject){
        calcularTotalVPLTabela({idTabelaVendas: tabelaSelecionadaObject.Id})
        .then(result =>{

             this.valorNominalTabelaSelecionada = result.valorNominal;
             this.valorVplTabelaSelecionada = result.valorVPL;

             this.obterSeriesTabelaVingente(this.valorNominalTabelaSelecionada, this.valorVplTabelaSelecionada, tabelaSelecionadaObject);
        })
    }


    obterSeriesTabelaVingente(valorNominal, valorVpl, tabelaVendaVigente){
            obterSeriesPorIdTabela({idTabela: tabelaVendaVigente.Id})
            .then(result => {

                let seriesPagamentos = [];
                result.forEach(element => {
                    let porcParcela = calcularPorcParcelaSeriePagamento(element.ValorTotal__c, element.QuantidadeParcelas__c);
                    let valorParcela = calcularValorParcelaSeriePagamento(porcParcela, valorNominal)
                    let valorTotal = calcularValorTotalSeriePagamento(element.ValorTotal__c, valorNominal)
                    seriesPagamentos.push(
                        {   
                            uid: this.generateUniqueId(),
                            TipoCondicao__c: element.TipoCondicao__c, 
                            InicioPagamento__c: calcularInicioPagamentoSeriePagamentos(element), 
                            vencimentoParcela: null,
                            QuantidadeParcelas__c: element.QuantidadeParcelas__c, 
                            ValorTotal__c: (element.ValorTotal__c).toFixed(2)+'%', 
                            AposHabiteSe__c: element.AposHabiteSe__c,
                            porcentagemParcela: (porcParcela).toFixed(2)+'%',
                            valorParcela: parseFloat(valorParcela).toFixed(2),
                            valorTotal: parseFloat(valorTotal).toFixed(2)
                        }
                    );
                });

                this.tabelaVendasVingenteValue = {idTabelaVingente: tabelaVendaVigente.Id, seriesPagamento: seriesPagamentos, valorNominal: valorNominal, valorVPL: valorVpl};
                
                this.tabelaVendasInfoComplementares = this.obterTabelaVendaInfoComplementares(tabelaVendaVigente)
                
                this.tabelaVendaSelecionada = JSON.parse(JSON.stringify(tabelaVendaVigente));


                this.propostasCliente = seriesPagamentos;

                this.calcularValorNominalProposta();
                this.calcularVplProposta();
            })
        }
    
        obterTabelaVendaInfoComplementares(tabelaVendas){
            if(!tabelaVendas){return;}

            let taxaDescontoVpl = tabelaVendas.TaxaDescontoVPL__c ? tabelaVendas.TaxaDescontoVPL__c : 0;
            let taxaTp = tabelaVendas.TaxaTP__c ? tabelaVendas.TaxaTP__c : 0;
            let antecipacaoAteHabitase = tabelaVendas.AntecipacaoAteHabiteSe__c ? tabelaVendas.AntecipacaoAteHabiteSe__c : 0;
            let antecipacaoAposHabitase = tabelaVendas.AntecipacaoAposHabiteSe__c ? tabelaVendas.AntecipacaoAposHabiteSe__c : 0;

            return  {taxaDescontoVpl: taxaDescontoVpl, taxaTp:  taxaTp, antecipacaoAteHabitase: antecipacaoAteHabitase, antecipacaoAposHabitase: antecipacaoAposHabitase}
        }


    adicionarNovaCondicao(){
        const novaCondicao = {
            uid: this.generateUniqueId(),
            TipoCondicao__c: null,
            InicioPagamento__c: null,
            vencimentoParcela: null,
            QuantidadeParcelas__c: null,
            valorParcela: null,
            valorTotal: null,
            porcentagemParcela: null,
            ValorTotal__c: null,
            AposHabiteSe__c: false
        };
        let propostasClienteClone = [...this.propostasCliente];
        propostasClienteClone.push(novaCondicao);
        this.propostasCliente = propostasClienteClone;

    }
    
    changeSeriesProposta(event){
        let seriesTabelaDeVenda = event.detail;
        this.propostasCliente = seriesTabelaDeVenda;
        
        this.calcularFinanceiroProposta();
    }


    deletarCondicao(event){
        let serieProposta = this.propostasCliente.find(serie => serie.uid === event.detail.uid);

        let updatedPropostasCliente = this.propostasCliente.filter(item => item.uid !== serieProposta.uid);

        this.propostasCliente = updatedPropostasCliente;
        
        this.calcularFinanceiroProposta();

        this.showNotification("Serie do tipo: " + serieProposta.TipoCondicao__c + " deletada com sucesso!" , "Novo valor nominal da proposta: " + this.formatCurrency(this.valorNominalProposta), "success");
    }

    handleZerarCondicao(event){
        let diferencaNominalTabelaProposta = Math.abs(this.valorNominalProposta - this.valorNominalTabelaSelecionada);

        let serieProposta = this.propostasCliente.find(serie => serie.uid === event.detail.uid);
        let valorSubtrairDoValorTotalProposta;
        let valorTotalPropostaRecalculado;
        let diferencaValorTotalValorTotalRecalculado;
        let valorSubtrairDoValorParcela;

        if(diferencaNominalTabelaProposta === 0){
            this.showNotification("Não há diferença para ser subtraida!", "", "info");
            return;
        }

        

        valorSubtrairDoValorParcela = diferencaNominalTabelaProposta / serieProposta.QuantidadeParcelas__c;
        
        valorTotalPropostaRecalculado = Math.abs((serieProposta.valorParcela - valorSubtrairDoValorParcela) * serieProposta.QuantidadeParcelas__c);

        diferencaValorTotalValorTotalRecalculado = serieProposta.valorTotal - valorTotalPropostaRecalculado

        valorSubtrairDoValorTotalProposta = Math.abs(diferencaValorTotalValorTotalRecalculado - diferencaNominalTabelaProposta)
   
        serieProposta.valorTotal = Math.abs(serieProposta.valorTotal - valorSubtrairDoValorTotalProposta);
       
        // let novaProposta = JSON.parse(JSON.stringify(serieProposta));
        // novaProposta.valorTotal -= valorSubtrairDoValorTotalProposta;
        // novaProposta.QuantidadeParcelas__c = 1;        
        // this.propostasCliente.push(novaProposta);

        this.showNotification("Valor total da parcela descontado!", "Valor descontado:  " + this.formatCurrency(valorSubtrairDoValorTotalProposta), "success");

        this.calcularFinanceiroProposta();
    }


    editarCondicao(event){
   
        const uid = event.detail.uid;
        const fieldName = event.detail.name;
        const fieldType = event.detail.type

 
        
        let newValue;
        
        let serieProposta = this.propostasCliente.find(serie => serie.uid === uid);
    
        if (fieldType === 'toggle') { 
            newValue = event.detail.checked;
        } else {
            newValue = event.detail.value;
        }


        serieProposta[fieldName] = newValue;
        


        
        if(fieldName != 'QuantidadeParcelas__c' && fieldName != 'valorParcela' && fieldName != 'valorTotal'){return;}


        switch(fieldName){
            case 'valorParcela':
                this.calcularValorTotalPropostaSerie(serieProposta);
            break;
            case 'valorTotal':
                this.calcularValorParcelaPropostaSerie(serieProposta);
            break;
            case 'QuantidadeParcelas__c':
                if(serieProposta.valorTotal === null){
                    this.calcularValorTotalPropostaSerie(serieProposta);
                    return;
                }

                if(serieProposta.valorParcela === null){
                    this.calcularValorParcelaPropostaSerie(serieProposta);
                    return;
                }

                this.calcularValorParcelaPropostaSerie(serieProposta);
            break;
        }



        this.calcularFinanceiroProposta()
        
    }

    setTabelaSelecionada(event){
        
        const {tabelaSelecionada, seriesPagamento, valorNominalTabela, valorVplTabela} = event.detail;

        
        this.tabelaVendaSelecionada = tabelaSelecionada;

        this.seriesVendaTabelaSelecionada = seriesPagamento;
        this.valorNominalTabelaSelecionada = valorNominalTabela;
        this.valorVplTabelaSelecionada = valorVplTabela;

        const propostasClienteString = JSON.stringify(this.propostasCliente.sort());
        const seriesPagamentoString = JSON.stringify(seriesPagamento.sort());

        if(!this.propostaTravada){
            this.propostasCliente = seriesPagamento;
            this.valorNominalProposta = valorNominalTabela
            this.valorVplProposta = valorVplTabela
        }

  

        this.ultimaTabelaSelecionada = {'tabelaVendaSelecionada': tabelaSelecionada, 'seriesTabela': seriesPagamento, 'valorNominal': valorNominalTabela, 'valorVpl': valorVplTabela}

        this.tabelaVendasInfoComplementares = this.obterTabelaVendaInfoComplementares(this.tabelaVendaSelecionada);
        
        this.propostaTravada = false;
    }

    calcularValorTotalPropostaSerie(propostaSerie){
        const {QuantidadeParcelas__c, valorParcela } = propostaSerie;
        if(QuantidadeParcelas__c == null || QuantidadeParcelas__c === 0 || valorParcela == null){
            return;
        }

        propostaSerie.valorTotal = QuantidadeParcelas__c * parseFloat(valorParcela);
    }

    calcularValorParcelaPropostaSerie(propostaSerie){

        const {QuantidadeParcelas__c, valorTotal } = propostaSerie;

        if(QuantidadeParcelas__c == null || QuantidadeParcelas__c == 0 || valorTotal == null){            
            return;
        }

        propostaSerie.valorParcela = parseFloat(valorTotal) / QuantidadeParcelas__c ;
    }

    calcularVplProposta() {

        let objetoSeriePagamentos=[];


        this.propostasCliente.forEach(serie=>{ 

            let periodicidadeSerie = serie.TipoCondicao__c ? periodicidades.find(tipoCondicao => tipoCondicao.tipoCondicao === serie.TipoCondicao__c) : null;
            

            objetoSeriePagamentos.push({
                id: serie.uid,
                nome: serie.TipoCondicao__c ? serie.TipoCondicao__c : null,
                valorTotal: serie.ValorTotal__c ? parseFloat(serie.ValorTotal__c.replace("%", "")) : 0.0,
                quantidadeParcelas: serie.QuantidadeParcelas__c ? parseInt(serie.QuantidadeParcelas__c) : 0,
                periodicidade: periodicidadeSerie ? parseInt(periodicidadeSerie.periodicidade) : 0,
                inicioPagamento: serie.InicioPagamento__c ? parseInt(calcularDiferencaMeses(serie.InicioPagamento__c)) : 0,
                tabelaVenda: this.tabelaVendaSelecionada.Id ? this.tabelaVendaSelecionada.Id : null,
                aposHabiteSe: serie.AposHabiteSe__c ? serie.AposHabiteSe__c : false,
                restante: false,
                valorNominalProposta: this.valorNominalProposta
            })
            
        })

        this.calcularTotalVplProposta(this.tabelaVendaSelecionada.Id, objetoSeriePagamentos);         
    }

    calcularValorNominalProposta(){
        let valorNominalProposta = 0;

        this.propostasCliente.forEach(serie=>{
            valorNominalProposta += parseFloat(serie.valorTotal)
        })
        

        this.valorNominalProposta = parseFloat(valorNominalProposta);            
    }

    

    calcularTotalVplProposta(idTabela, seriesPagamentoProposta){
        calcularTotalVPLProposta({idTabelaVendas: idTabela, objetosSeries: seriesPagamentoProposta, valorTotalProposta: this.valorNominalProposta})
        .then(result=>{
            this.valorVplProposta = 0;

            let valorVPL = parseFloat(result.valorVPL)
            
            this.valorVplProposta = valorVPL ? valorVPL.toFixed(2) : 0;

        }).catch(error=>{
            console.log(error)
        })
    }

    calcularPorcentagensProposta(){
         this.propostasCliente.forEach(serie=>{
            const {QuantidadeParcelas__c, valorParcela, valorTotal } = serie;
            if(QuantidadeParcelas__c == null || valorParcela == null){return;}

            let porcValorTotal = (valorTotal / this.valorNominalProposta) * 100;
            let porcParcela = porcValorTotal / QuantidadeParcelas__c;


            serie.ValorTotal__c = porcValorTotal ? `${(porcValorTotal).toFixed(2)}%` : '0.00%';
            serie.porcentagemParcela = porcParcela ? `${(porcParcela).toFixed(2)}%` : '0.00%';
         })


                
    }

    igualarTabelas(){
        this.propostasCliente =  JSON.parse(JSON.stringify(this.seriesVendaTabelaSelecionada));
        this.valorNominalProposta = this.valorNominalTabelaSelecionada;
        this.valorVplProposta = this.valorVplTabelaSelecionada;
        
    }

    pagarAVista(){
        let propostasClienteClone = [];

        let dataAtual = new Date();
        let dataAtualFormatada = dataAtual.toISOString().split('T')[0];

        propostasClienteClone.push ({
            uid: this.generateUniqueId(),
            TipoCondicao__c: 'Ato',
            InicioPagamento__c: dataAtualFormatada,
            vencimentoParcela: null,
            QuantidadeParcelas__c: 1,
            valorParcela: this.valorNominalTabelaSelecionada,
            valorTotal: this.valorNominalTabelaSelecionada,
            porcentagemParcela: null,
            ValorTotal__c: null,
            AposHabiteSe__c: false
        })

        this.propostasCliente = propostasClienteClone;

        this.calcularFinanceiroProposta();
    }

    aplicarDescontoProposta(event){
        const descontosSeries = event.detail;

        descontosSeries.forEach(descontoSerie =>{
            let serieProposta = this.propostasCliente.find(serie => serie.uid === descontoSerie.uid);

            serieProposta.valorTotal = descontoSerie.valorTotalComDesconto;
            serieProposta.valorParcela = serieProposta.valorTotal / serieProposta.QuantidadeParcelas__c;
           
        })

        this.propostasCliente = [...this.propostasCliente]

        this.calcularFinanceiroProposta();

        this.showNotification("Desconto aplicado!", "", "success")
    }

    calcularQtdParcela(seriePagamento){
        return seriePagamento.valorTotal / QuantidadeParcelas__c
    }

    calcularFinanceiroProposta(){
        //calcula valor nominal com base no valorTotal (currency) das series de pagamento
        this.calcularValorNominalProposta();

        this.calcularPorcentagensProposta();

        this.calcularVplProposta()


    }
    

    generateUniqueId() {
        return 'id-' + Math.random().toString(36).substr(2, 9);
    }

    formatCurrency(value) {
        if (!value) return 'R$ 0,00';
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    }

    limparDadosSimulacao(){
        this.tabelaVendasVingenteValue = undefined;
        this.ultimaTabelaSelecionada = undefined;
        this.tabelaVendaSelecionada = undefined;
        this.seriesVendaTabelaSelecionada = undefined;
        this.tabelaVendasInfoComplementares = undefined;
        this.valorNominalTabelaSelecionada = undefined;
        this.valorVplTabelaSelecionada = undefined;
        this.propostasCliente = undefined;
        this.valorNominalProposta = undefined;
        this.valorVplProposta = undefined;
        this.idProdutoSelecionado = undefined;
    }

    concluirSimulacao(){
        let SeriesPagamento__c = []

        this.propostasCliente.forEach(serie=>{
            let periodicidadeSerie = serie.TipoCondicao__c ? periodicidades.find(tipoCondicao => tipoCondicao.tipoCondicao === serie.TipoCondicao__c) : null;
            
            SeriesPagamento__c.push({
                TipoCondicao__c: serie.TipoCondicao__c,
                InicioPagamento__c: serie.InicioPagamento__c,
                QuantidadeParcelas__c: serie.QuantidadeParcelas__c,
                ValorTotal__c: serie.ValorTotal__c,
                AposHabiteSe__c: serie.AposHabiteSe__c,
                TabelaVenda__c: null,
                
            })
        })

        criarTabelaDaSimulacao({seriesDeProposta: SeriesPagamento__c, idCotacao: this.getCotacaoId, nomeCotacao: this.getCotacaoName, tabelaSelecionada: this.tabelaVendaSelecionada})
        .then(result=>{
            this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'TabelaVendas__c',
                        actionName: 'view'
                    }
            });
        })
        .catch(error=>{
            console.error(error)
            this.showNotification("Erro ao concluir simulacao", "Verifique os campos de entrada", "error")
        })
    }


}