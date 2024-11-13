@isTest
private class CotacaoControllerTest {@TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Opportunity oportunidade = TestDataFactory.gerarOportunidade(conta.Id);
        insert oportunidade;

        Product2 produto = TestDataFactory.gerarProduto();
        produto.Empreendimento__c = empreendimento.Id;
        insert produto;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.Id;
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.id);
        insert serie;
    }

    @isTest
    static void obterEntradaPrecoPorUnidadeTest() {
        TabelaVendas__c tabela = [SELECT Id, Empreendimento__c FROM TabelaVendas__c LIMIT 1];
        Id unidadeId = [SELECT Id FROM Product2 WHERE Empreendimento__c = :tabela.Empreendimento__c LIMIT 1].Id;

        Test.startTest();

        Map<Id, UnidadeTabelaVendas__c> mapEntradaPreco = CotacaoController.obterEntradaPrecoPorUnidade(tabela.Id);

        Assert.isTrue(mapEntradaPreco.size() > 0, 'O retorno esta vazio.');
        Assert.isNotNull(mapEntradaPreco.get(unidadeId), 'A entrada não foi encontrada.');

        Test.stopTest();
    }

    @isTest
    static void criarCotacaoPorOportunidadeTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Quote cotacao;

        try {
            CotacaoController.criarCotacaoPorOportunidade(null); 
            Assert.fail('Exceção esperada');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'A mensagem de erro não deve ser nula');
        }

        try {
            cotacao = CotacaoController.criarCotacaoPorOportunidade(opp.Id);
        } catch (AuraHandledException e) {
            Assert.fail('Exceção não esperada');
        }


        Assert.isNotNull(cotacao);
        Test.stopTest();
    }

    @isTest
    static void criarQuoteLineItemsTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote cotacao = CotacaoController.criarCotacaoPorOportunidade(opp.Id);
        
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Id pbeId = [SELECT Id FROM PricebookEntry LIMIT 1].Id;

        QuoteLineItem qli = new QuoteLineItem(
            UnitPrice = 10,
            Quantity = 10,
            PricebookEntryId = pbeId,
            QuoteId = cotacao.Id,
            Product2Id = productId
        );

        Test.startTest();
        List<QuoteLineItem> cotacoes = CotacaoController.criarQuoteLineItems(new List<QuoteLineItem>{qli});

        Assert.isFalse(cotacoes.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void concluirSimulacaoTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote cotacao = CotacaoController.criarCotacaoPorOportunidade(opp.Id);
        Id idCotacao = cotacao.Id;
        
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        Id pbeId = [SELECT Id FROM PricebookEntry LIMIT 1].Id;

        List<QuoteLineItem> qlis = new List<QuoteLineItem>{
            new QuoteLineItem(
                UnitPrice = 10,
                Quantity = 10,
                PricebookEntryId = pbeId,
                QuoteId = cotacao.Id,
                Product2Id = productId
            )
        };

        List<SeriePagamentos__c> series = new List<SeriePagamentos__c>{
            new SeriePagamentos__c(
                Name = '000',
                Cotacao__c = cotacao.Id
            ),
            new SeriePagamentos__c(
                Name = '001',
                Cotacao__c = cotacao.Id
            )
        };

        Test.startTest();
        try {
            CotacaoController.concluirSimulacao(null, null, null, null, null);
            Assert.fail('Exceção esperada');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'A mensagem de erro não deve ser nula');
        }

        try {
            CotacaoController.concluirSimulacao(series, qlis, idCotacao, false, 30000.0d);
        } catch (AuraHandledException e) {
            Assert.fail('Exceção não esperada');
        }
        
        Test.stopTest();
        
    }

    @isTest
    static void buscarSeriesPorCotacaoTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote cotacao = CotacaoController.criarCotacaoPorOportunidade(opp.Id);

        Test.startTest();

        insert new SeriePagamentos__c(Cotacao__c = cotacao.Id, Name = '000');
        insert new SeriePagamentos__c(Cotacao__c = cotacao.Id, Name = '001');

        List<SeriePagamentos__c> series = CotacaoController.buscarSeriesPorCotacao(cotacao.Id);


        Assert.isFalse(series.isEmpty(), 'A lista series não pode estar vazia');
        Assert.isTrue(series.size() == 2, 'A lista series não pode estar com tamanho diferente de 2');
        Test.stopTest();
    }
}