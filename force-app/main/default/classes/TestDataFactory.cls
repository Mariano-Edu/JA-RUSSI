public class TestDataFactory {

    //Registros objetos padrão
    public static Account gerarConta(){
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.CNPJ__c = '66077848000127';
        return conta;
    }

    public static Product2 gerarProduto() {
        Product2 produto = new Product2();
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        produto.NumeroDaUnidade__c = 777;
        return produto;
    }

    public static PricebookEntry  gerarPricebookEntry(Id idProduto){
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = idProduto;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;
        return pricebookEntry;
}

    //Registros simulador de vendas
    public static Empreendimento__c gerarEmpreendimento() {
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJ__c = '22151181000190';
        return empreendimento;
    }

    public static TabelaVendas__c gerarTabelaVendas(){
        TabelaVendas__c tabelaVendas = new TabelaVendas__c();
        tabelaVendas.Name = 'Teste'; 
        tabelaVendas.PeriodicidadeParcelaPos__c = 1;
        tabelaVendas.PeriodicidadeParcela__c = '1';
        return tabelaVendas;
    }

    public static SeriePagamentos__c gerarSeriePagamento(Id idTabela){
        SeriePagamentos__c serie = new SeriePagamentos__c();
        serie.Name = 'Teste';
        serie.InicioPagamento__c = 1;
        serie.QuantidadeParcelas__c = 1;
        serie.ValorTotal__c= 1;
        serie.TabelaVenda__c = idTabela;
        serie.TipoCondicao__c = 'Ato';
        return serie;
    }

    public static SeriePagamentosService.ObjetoSerie gerarObjetoSerie(String nomeSerie, Id idTabelaVenda){
        SeriePagamentosService.ObjetoSerie serie = new SeriePagamentosService.ObjetoSerie();
        serie.nome = nomeSerie;
        serie.valorTotal = 4; 
        serie.quantidadeParcelas = 1;
        serie.periodicidade = 1;
        serie.inicioPagamento = 0;
        serie.aposHabiteSe = false;
        return serie;
    }

    public static UnidadeTabelaVendas__c gerarUnidadeTabelaVendas(Id idTabela){
        UnidadeTabelaVendas__c unidadeVenda = new UnidadeTabelaVendas__c();
        unidadeVenda.Name = 'UnidadeVendaTeste';
        unidadeVenda.TabelaVenda__c = idTabela;
        unidadeVenda.PrecoLista__c = 300000;
        return unidadeVenda;
    }

    public static Quote gerarCotacao(Id idTabela, Id idOpp) {
        Quote cotacao = new Quote();
        cotacao.Name = 'Cotação Teste';
        cotacao.TabelaDeVenda__c = idTabela;
        cotacao.OpportunityId = idOpp;
        return cotacao;
    }

    public static Opportunity gerarOportunidade(Id idConta) {
        Opportunity opp = new Opportunity();
        opp.Name = 'Oportunidade 1';
        opp.StageName = 'Proposta';
        opp.CloseDate = System.today().addMonths(1);
        opp.AccountId = idConta;
        //opp.ResponsavelPeloLead__c = user.Id;
        return opp;
    }
}