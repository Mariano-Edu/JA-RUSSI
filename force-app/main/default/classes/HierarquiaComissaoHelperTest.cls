@isTest
public class HierarquiaComissaoHelperTest {

    @testSetup
    static void setupTestData() {
        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();

        TabelaComissao__c tabelaComissao = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas.Id, empreendimento.Id);
        tabelaComissao.ValorPremio__c = 10000.0;
        tabelaComissao.PercentualComissao__c = 15.0;
        insert tabelaComissao;

        HierarquiaComissao__c hierarquiaExistente = new HierarquiaComissao__c();
        hierarquiaExistente.TabelaComissao__c = tabelaComissao.Id;
        hierarquiaExistente.Cargo__c = 'Gerente de vendas';
        hierarquiaExistente.ValorPremio__c = 2000.0;
        hierarquiaExistente.PercentualComissao__c = 5.0;
        insert hierarquiaExistente;
    }

    @isTest
    static void testHandleBeforeInsertValidHierarchy() {
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        HierarquiaComissao__c novaHierarquia = new HierarquiaComissao__c();
        novaHierarquia.TabelaComissao__c = tabelaComissao.Id;
        novaHierarquia.Cargo__c = 'SDR';
        novaHierarquia.ValorPremio__c = 3000.0;
        novaHierarquia.PercentualComissao__c = 3.0;

        Test.startTest();
        HierarquiaComissaoHelper.handleBeforeInsert(new List<HierarquiaComissao__c>{novaHierarquia});
        Test.stopTest();

        Assert.isFalse(novaHierarquia.hasErrors(), 'Não deve haver erros');
    }

    @isTest
    static void testHandleBeforeInsertExceedingValorPremio() {
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        HierarquiaComissao__c novaHierarquia = new HierarquiaComissao__c();
        novaHierarquia.TabelaComissao__c = tabelaComissao.Id;
        novaHierarquia.Cargo__c = 'SDR';
        novaHierarquia.ValorPremio__c = 9000.0;
        novaHierarquia.PercentualComissao__c = 2.0;

        Test.startTest();
        HierarquiaComissaoHelper.handleBeforeInsert(new List<HierarquiaComissao__c>{novaHierarquia});
        Test.stopTest();

        Assert.isTrue(novaHierarquia.hasErrors(), 'Deveria lançar erro por exceder o limite de prêmio da tabela de comissão');
    }

    @isTest
    static void testHandleBeforeInsertExceedingPercentual() {
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        HierarquiaComissao__c novaHierarquia = new HierarquiaComissao__c();
        novaHierarquia.TabelaComissao__c = tabelaComissao.Id;
        novaHierarquia.Cargo__c = 'SDR';
        novaHierarquia.ValorPremio__c = 1000.0;
        novaHierarquia.PercentualComissao__c = 11.0;

        Test.startTest();
        HierarquiaComissaoHelper.handleBeforeInsert(new List<HierarquiaComissao__c>{novaHierarquia});
        Test.stopTest();
        
        Assert.isTrue(novaHierarquia.hasErrors(), 'Deveria ter lançado um erro por exceder o percentual');
    }

    @isTest
    static void testHandleBeforeInsertDuplicateCargo() {
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        HierarquiaComissao__c novaHierarquia = new HierarquiaComissao__c();
        novaHierarquia.TabelaComissao__c = tabelaComissao.Id;
        novaHierarquia.Cargo__c = 'Gerente de vendas';
        novaHierarquia.ValorPremio__c = 1000.0;
        novaHierarquia.PercentualComissao__c = 2.0;

        Test.startTest();
        HierarquiaComissaoHelper.handleBeforeInsert(new List<HierarquiaComissao__c>{novaHierarquia});
        Test.stopTest();

        Assert.isTrue(novaHierarquia.hasErrors(), 'Deveria ter lançado um erro por cargo duplicado.');
    }
}