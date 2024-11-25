@isTest
public class TabelaComissaoSelectorTest {

    @testSetup
    static void setupTestData() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        TabelaComissao__c tabelaComissaoAtivada = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas.Id, empreendimento.Id);
        insert tabelaComissaoAtivada;

        TabelaComissao__c tabelaComissaoDesativada = TestDataFactory.gerarTabelaComissaoDesativada(tabelaVendas.Id, empreendimento.Id);
        insert tabelaComissaoDesativada;
    }

    @isTest
    static void testGetTabelasComissao() {
        TabelaVendas__c tabelaVendas = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        TabelaComissao__c tabelaComissaoAtivada = [
            SELECT Id FROM TabelaComissao__c WHERE Ativa__c = true LIMIT 1
        ];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoSelector.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'House'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa');
        Assert.areEqual(tabelaComissaoAtivada.Id, resultados[0].Id, 'A tabela de comissão retornada deve ser a ativa');
    }
}