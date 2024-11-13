import { LightningElement, track, api } from 'lwc';


export default class SimuladorTelaNegociacao extends LightningElement {
    
    @api produtoSelecionado;
    @api propostasCliente;
    @api valorNominalProposta;
    @api valorVplProposta;
    @api infoComplementares;

    @api ultimaTabelaSelecionada;
    @api tabelasDeVendasData;
    @api tabelaVendaVingenteValue;

    @api tabelasVendas;
    @api tabelaOptions;
    @api tabelaSelecionada;
    @api unidadeSelecionada;

    @api entradaPrecosMap;
    @api tabelaMesVigencia;
    
    @api descontoNominal;
    @api descontoPercentual;

    get getTabelasDeVendasData(){
        return this.tabelasDeVendasData;
    }

    get getTabelaMesVigencia(){
        return this.tabelaMesVigencia;
    }
    
    get getProdutoSelecionado(){
        return this.produtoSelecionado;
    }
    
    get getTabelasVendas(){
        return this.tabelasVendas;
    }

    get getTabelaOptions(){
        return this.tabelaOptions;
    }

    get getTabelaSelecionada(){
        return this.tabelaSelecionada;
    }

    get getUnidadeSelecionada(){
        return this.unidadeSelecionada;
    }

    get getEntradaPrecosMap(){
        return this.entradaPrecosMap;
    }

    get getDescontoNominal() {
        return this.descontoNominal;
    }

    get getDescontoPercentual() {
        return this.descontoPercentual;
    }

    handleSetTabelaSelecionada(event){
        this.dispatchEvent(new CustomEvent('settabelaselecionada', {
            detail: event.detail
        }));
    }

    handleIgualarTabelas(){
        console.log(1);
        this.dispatchEvent(new CustomEvent('handleigualartabelas'));
        console.log(2);
    }

    handlePagarAVista(event){
        this.dispatchEvent(new CustomEvent('handlepagaravista', {
            detail: event.detail
        }));
    }

    changeSeriesPagamentoProposta(event){
        this.dispatchEvent(new CustomEvent('changepropostaserie', {
            detail: event.detail
        }));
    }

    handleAdicionarCondicaoData(){
        this.dispatchEvent(new CustomEvent('adicionarcondicao'));
    }

    handleDeleteCondicaoData(event){
        
        this.dispatchEvent(new CustomEvent('deletarcondicao', {
            detail: event.detail
        }));
    }

    handleZerarCondicao(event){
        this.dispatchEvent(new CustomEvent('zerarcondicao', {
            detail: event.detail
        }));
    }

    handleSelecionarSerie(event) {
        this.dispatchEvent(new CustomEvent('selecionarserie', {
            detail: event.detail
        }));
    }



    handleChangeCondicaoData(event){
        
        this.dispatchEvent(new CustomEvent('mudarcondicao', {
            detail: event.detail
        }));
    }

    handleAplicarDesconto(event){
        const descontoEvent = new CustomEvent('aplicardesconto', {
            detail: event.detail
        });

        this.dispatchEvent(descontoEvent); 

    }

    activeSections = ['Selecione uma tabela de vendas', 'Proposta do cliente'];
    


}