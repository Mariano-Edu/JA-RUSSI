@isTest
private class TabelaVendasHelperTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c> {
            TestDataFactory.gerarEmpreendimento(),
            TestDataFactory.gerarEmpreendimento()
        };

        insert empreendimentos;

        TabelaVendas__c tabela1 = TestDataFactory.gerarTabelaVendas();
        tabela1.Empreendimento__c = empreendimentos.get(0).Id;
        insert tabela1;

        TabelaVendas__c tabela2 = TestDataFactory.gerarTabelaVendas();
        tabela2.Empreendimento__c = empreendimentos.get(1).Id;
        insert tabela2;

        Product2 produto1 = TestDataFactory.gerarProduto();
        produto1.Empreendimento__c = empreendimentos.get(1).Id;
        insert produto1;

        Product2 produto2 = TestDataFactory.gerarProduto();
        produto2.Empreendimento__c = empreendimentos.get(0).Id;
        insert produto2;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela2.id);
        unidadeTabela.Unidade__c = produto1.Id;
        insert unidadeTabela;

        insert TestDataFactory.gerarUnidadeTabelaVendas(tabela2.id);

        Map<String, RecordType> recordTypes = new Map<String, RecordType>();
        Set<String> recordTypeTypes = new Set<String>{'Account', 'Contact'};

        Profile profile = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1];

        User user = new User(
            Alias = 'user1',
            Email = 'test@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test240920241005y@email.com',
            profileId = profile.Id
        );

        insert user;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '10155540000106'
        );

        insert empreendimento;

        Bloco__c bloco = new Bloco__c(
            Name = 'Torre A',
            Empreendimento__c = empreendimento.Id
        );

        insert bloco;

        Product2 unidade = new Product2(
            Name = 'Unidade',
            Bloco__c = bloco.Id,
            NumeroDaUnidade__c = 1
        );

        insert unidade;

        TabelaVendas__c tabelaVendas = new TabelaVendas__c(
            Name = 'Tabela Teste',
            Clonado__c = false

        );
        
        insert tabelaVendas;

        SerieDePagamento__c serieOrigem = new SerieDePagamento__c(
            TabelaDeVenda__c = tabelaVendas.Id,
            Periodicidade__c = 'Mensal',
            DataPrimeiroVencimento__c = Date.newInstance(2024, 11, 1),
            Entrada__c = true,
            Fixa__c = true,
            Juros__c = true,
            Parcelas__c = 12,
            PercentualValorUnidade__c = 10
        );
        
        insert serieOrigem;

      
    }

    @isTest
    public static void validateDuplicatesTest() {
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
    
        TabelaVendas__c tabelaVenda = new TabelaVendas__c(
            Name = 'Tabela Teste 2',
            Clonado__c = false,
            Empreendimento__c = empreendimento.Id,
            VigenciaInicio__c = Date.newInstance(2024, 10, 1),
            VigenciaFim__c = Date.newInstance(2024, 11, 1)
        );
    
        insert tabelaVenda;
    
        TabelaVendas__c tabelaVendaDuplicada = new TabelaVendas__c(
            Name = 'Tabela Teste 2',
            Clonado__c = false,
            Empreendimento__c = empreendimento.Id,
            VigenciaInicio__c = Date.newInstance(2024, 10, 1),
            VigenciaFim__c = Date.newInstance(2024, 11, 1)
        );
    
        TabelaVendas__c tabelaVendaTeste = new TabelaVendas__c(
            Name = 'Tabela Teste 3',
            Clonado__c = null,
            Empreendimento__c = empreendimento.Id,
            VigenciaInicio__c = Date.newInstance(2024, 10, 1),
            VigenciaFim__c = Date.newInstance(2024, 11, 1)
        );
    
        TabelaVendas__c tabelaVendaSobreposta = new TabelaVendas__c(
            Name = 'Tabela Teste 4',
            Clonado__c = false,
            Empreendimento__c = empreendimento.Id,
            VigenciaInicio__c = Date.newInstance(2024, 10, 15), 
            VigenciaFim__c = Date.newInstance(2024, 11, 15)
        );
    
        Test.startTest();
        try {
            TabelaVendasHelper.validateDuplicates(new List<TabelaVendas__c> { tabelaVendaDuplicada });
            insert tabelaVendaDuplicada; 
            System.assert(false, 'Deveria ter lançado uma exceção ao inserir um registro duplicado');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Não é possível criar uma tabela de vendas com dados repetidos: mesmo empreendimento, datas e percentual.'), 'A mensagem de erro deve ser a correta.');
        }
    
        try {
            TabelaVendasHelper.validateDuplicates(new List<TabelaVendas__c> { tabelaVendaTeste });
            insert tabelaVendaTeste;
            System.assert(false, 'Deveria ter lançado uma exceção ao não informar se é uma tabela clonada ou não.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Informe se é uma tabela clonada ou não.'), 'A mensagem de erro deve ser a correta.');
        }
    
        try {
            TabelaVendasHelper.validateDuplicates(new List<TabelaVendas__c> { tabelaVendaSobreposta });
            insert tabelaVendaSobreposta; 
            System.assert(false, 'Deveria ter lançado uma exceção ao inserir uma tabela com datas sobrepostas');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('As datas de vigência não podem se sobrepor às datas de uma tabela existente para o mesmo empreendimento.'), 'A mensagem de erro deve ser a correta.');
        }
    

        Test.stopTest();
    }
    

    @isTest
    public static void updateAtivoTest(){

        Empreendimento__C empreendimento = [SELECT Id FROM Empreendimento__C LIMIT 1];

        TabelaVendas__c tabelaVenda = new TabelaVendas__c(
            Name = 'Tabela Teste 3',
            Clonado__c = false,
            
            VigenciaInicio__c = Date.newInstance(2024, 10, 14),
            VigenciaFim__c = Date.newInstance(2024, 10, 15), 
            Ativo__c = false

        );
        insert tabelaVenda;

        Test.startTest();

        TabelaVendasHelper.updateAtivo(new List<TabelaVendas__c> { tabelaVenda });
        
        tabelaVenda.Empreendimento__c = empreendimento.Id;
        
        tabelaVenda.Ativo__c = true;
        update tabelaVenda;
        
        Test.stopTest();
    }

    @isTest
    public static void ValidateIdDeOrigemTest() {
        TabelaVendas__c tabelaOrigem = new TabelaVendas__c(
            Name = 'Tabela Origem',
            Clonado__c = false,
            VigenciaInicio__c = Date.newInstance(2024, 10, 1),
            VigenciaFim__c = Date.newInstance(2024, 10, 31),
            Ativo__c = false
        );

        insert tabelaOrigem;

        TabelaVendas__c tabelaReferencia = new TabelaVendas__c(
            Name = 'Tabela Referência',
            Clonado__c = false,
            VigenciaInicio__c = Date.newInstance(2024, 11, 1),
            VigenciaFim__c = Date.newInstance(2024, 11, 30),
            Ativo__c = false,
            IdDeOrigem__c = tabelaOrigem.Id
        );

        insert tabelaReferencia;

        Map<Id, List<SerieDePagamento__c>> tabelaToSeriesMap = new Map<Id, List<SerieDePagamento__c>>();
        List<SerieDePagamento__c> seriesPagamentoList = new List<SerieDePagamento__c> {
            new SerieDePagamento__c(TabelaDeVenda__c = tabelaOrigem.Id, Periodicidade__c = 'Mensal'),
            new SerieDePagamento__c(TabelaDeVenda__c = tabelaOrigem.Id, Periodicidade__c = 'Única')
        };
        insert seriesPagamentoList;

        tabelaToSeriesMap.put(tabelaOrigem.Id, seriesPagamentoList);

        Test.startTest();
        TabelaVendasHelper.cloneRecords(new List<TabelaVendas__c> { tabelaReferencia });
        Test.stopTest();

        List<SerieDePagamento__c> novasSeries = [SELECT Id, TabelaDeVenda__c, Periodicidade__c, Type__c 
            FROM SerieDePagamento__c WHERE TabelaDeVenda__c = :tabelaReferencia.Id];

        System.assertEquals(2, novasSeries.size(), 'Duas séries de pagamento devem ser clonadas.');
        System.assertEquals('Mensal', novasSeries[0].Periodicidade__c, 'A periodicidade da série clonada deve ser igual.');
    }
    @isTest
    public static void calculateValuesTest() {
        Empreendimento__c empreendimento2 = new Empreendimento__c(
            Name = 'Empreendimento Teste2',
            CNPJ__c = '10155540000106'
        );
        insert empreendimento2;

        TabelaVendas__c tabelaAnterior = new TabelaVendas__c(
            Name = 'Tabela Anterior',
            Clonado__c = false,
            Empreendimento__c = empreendimento2.Id,
            ValorDeLista__c = 1000,
            ValorDeVenda__c = 1000,
            PercentualDeAcrescimo__c = 0,
            VigenciaInicio__c = Date.newInstance(2024, 10, 1),
            VigenciaFim__c = Date.newInstance(2024, 10, 15)
        );
        insert tabelaAnterior;

        TabelaVendas__c tabelaClonada = new TabelaVendas__c(
            Name = 'Tabela Clonada',
            Clonado__c = true,
            Empreendimento__c = tabelaAnterior.Empreendimento__c,
            ValorDeLista__c = 1000,
            PercentualDeAcrescimo__c = 20,
            VigenciaInicio__c = Date.newInstance(2024, 10, 16),
            VigenciaFim__c = Date.newInstance(2024, 10, 31)
        );

        Test.startTest();
        TabelaVendasHelper.validateDuplicates(new List<TabelaVendas__c> { tabelaClonada });
        insert tabelaClonada; 
        Test.stopTest();

        tabelaClonada = [SELECT ValorDeVenda__c, ValorDeAcrescimo__c,PercentualDeAcrescimo__c FROM TabelaVendas__c WHERE Id = :tabelaClonada.Id];
        Decimal esperadoValorAcrescimo = tabelaAnterior.ValorDeVenda__c * (tabelaClonada.PercentualDeAcrescimo__c / 100); 
        Decimal esperadoValorVenda = tabelaAnterior.ValorDeVenda__c + esperadoValorAcrescimo; 

        System.assertEquals(esperadoValorAcrescimo, tabelaClonada.ValorDeAcrescimo__c, 'O valor de acréscimo deve ser calculado corretamente.');
        System.assertEquals(esperadoValorVenda, tabelaClonada.ValorDeVenda__c, 'O valor de venda deve ser calculado corretamente.');
    }

    @isTest
    private static void inserirUnidadesTabelasInsertTest() {
        Set<Id> idsTabelasComUnidade = ObjectHelper.getLookUpId(
            [SELECT TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c != null],
            'TabelaVenda__c'
        );

        List<TabelaVendas__c> tabelas = [
            SELECT
                Id,
                Empreendimento__c
            FROM TabelaVendas__c WHERE Id NOT IN :idsTabelasComUnidade
        ];

        Test.startTest();
        TabelaVendasHelper.inserirUnidadesTabelas(tabelas);
        Test.stopTest();

        List<UnidadeTabelaVendas__c> unidadesTabelas = [
            SELECT 
                Id
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :(new Map<Id,TabelaVendas__c>(tabelas).keySet())
        ];

        Assert.isFalse(unidadesTabelas.isEmpty());
    }

    @isTest
    private static void inserirUnidadesTabelasUpdateTest() {
        Set<Id> idsTabelasComUnidade = ObjectHelper.getLookUpId(
            [SELECT TabelaVenda__c FROM UnidadeTabelaVendas__c WHERE TabelaVenda__c != null],
            'TabelaVenda__c'
        );

        List<TabelaVendas__c> tabelas = [
            SELECT
                Id,
                Empreendimento__c
            FROM TabelaVendas__c WHERE Id IN :idsTabelasComUnidade
        ];

        UnidadeTabelaVendas__c unidadesTabela = [
            SELECT 
                Id,
                Name,
                PrecoLista__c,
                CoeficienteTabela__c,
                MetragemUnidade__c,
                Unidade__c,
                TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :idsTabelasComUnidade
            LIMIT 1
        ];

        Test.startTest();
        TabelaVendasHelper.inserirUnidadesTabelas(tabelas);
        Test.stopTest();

        UnidadeTabelaVendas__c unidadesTabelaUpdated = [
            SELECT 
                Id,
                Name,
                PrecoLista__c,
                CoeficienteTabela__c,
                MetragemUnidade__c,
                Unidade__c,
                TabelaVenda__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c IN :idsTabelasComUnidade
            LIMIT 1
        ];

        Assert.areNotEqual(unidadesTabela, unidadesTabelaUpdated);
    }
}