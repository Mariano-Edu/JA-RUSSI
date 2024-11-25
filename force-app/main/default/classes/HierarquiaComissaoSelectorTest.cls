@isTest
public class HierarquiaComissaoSelectorTest {
    @testSetup
    static void setup() {
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        TabelaComissao__c tabelaComissao = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas.Id, empreendimento.Id);
        insert tabelaComissao;

        insert new List<HierarquiaComissao__c> {
            new HierarquiaComissao__c(
                PercentualComissao__c = 7.0,
                TabelaComissao__c = tabelaComissao.Id,
                ValorPremio__c = 500,
                Cargo__c = 'Diretor Comercial'
            ),
            new HierarquiaComissao__c(
                PercentualComissao__c = 3.0,
                TabelaComissao__c = tabelaComissao.Id,
                Cargo__c = 'Gerente de vendas'
            )
        };
    }

    @isTest
    static void testGetHierarquiasByTabelaComissao() {
        TabelaComissao__c tabelaComissao = [SELECT Id FROM TabelaComissao__c LIMIT 1];

        Test.startTest();
        List<HierarquiaComissao__c> hierarquias = HierarquiaComissaoSelector.getHierarquiasByTabelaComissao(tabelaComissao.Id);
        Test.stopTest();

        Assert.isNotNull(hierarquias, 'A lista de hierarquias não deve ser nula.');
        Assert.isTrue(hierarquias.size() == 2, 'Devem existir exatamente 2 hierarquias associadas à tabela de comissão.');

        HierarquiaComissao__c hierarquia1 = hierarquias[0];
        Assert.isTrue(hierarquia1.Cargo__c == 'Diretor Comercial', 'O primeiro cargo deve ser "Diretor Comercial".');
        Assert.isTrue(hierarquia1.PercentualComissao__c == 7.0, 'O percentual de comissão do primeiro cargo deve ser 7%.');
        Assert.isTrue(hierarquia1.ValorPremio__c == 500, 'O valor do prêmio do primeiro cargo deve ser R$500,00.');

        HierarquiaComissao__c hierarquia2 = hierarquias[1];
        Assert.isTrue(hierarquia2.Cargo__c == 'Gerente de vendas', 'O segundo cargo deve ser "Gerente de vendas".');
        Assert.isTrue(hierarquia2.PercentualComissao__c == 3.0, 'O percentual de comissão do segundo cargo deve ser 3%.');
    }
}