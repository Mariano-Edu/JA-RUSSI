@isTest
public class TabelaComissaoControllerTest {

    @testSetup
    static void setupTestData() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabelaVendasHouse = TestDataFactory.gerarTabelaVendas();
        tabelaVendasHouse.Name = 'TabelaVendaHouse';
        insert tabelaVendasHouse;

        TabelaVendas__c tabelaVendasParceiro = TestDataFactory.gerarTabelaVendas();
        tabelaVendasParceiro.Name = 'TabelaVendaParceiro';
        insert tabelaVendasParceiro;

        TabelaComissao__c tabelaComissaoHouse = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendasHouse.Id, empreendimento.Id);
        tabelaComissaoHouse.EmpresaVenda__c = 'House';
        insert tabelaComissaoHouse;

        TabelaComissao__c tabelaComissaoParceiro = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendasParceiro.Id, empreendimento.Id);
        tabelaComissaoParceiro.EmpresaVenda__c = 'Parceiro';
        insert tabelaComissaoParceiro;
    }

    @isTest
    static void testGetTabelasComissaoForHouse() {
        TabelaVendas__c tabelaVendas = [SELECT Id FROM TabelaVendas__c WHERE Name = 'TabelaVendaHouse' LIMIT 1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoController.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'House'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa para "House".');
        Assert.areEqual('House', resultados[0].EmpresaVenda__c, 'A tabela de comissão deve pertencer à empresa "House".');
    }

    @isTest
    static void testGetTabelasComissaoForParceiro() {
        TabelaComissao__c tabelaVendas = [SELECT Id, EmpresaVenda__c FROM TabelaComissao__c WHERE EmpresaVenda__c = 'Parceiro' LIMIT 1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoController.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'Parceiro'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa para "Parceiro".');
        Assert.areEqual('Parceiro', resultados[0].EmpresaVenda__c, 'A tabela de comissão deve pertencer à empresa "Parceiro".');
    }

    @isTest
    static void testGetTabelasComissaoWithException() {
        Test.startTest();
        try {
            TabelaComissaoController.getTabelasComissao(null, null, null);
        } catch (AuraHandledException e) {
            Assert.areEqual(
                'Parâmetros inválidos para consulta de tabelas de comissão.', 
                e.getMessage(), 
                'A mensagem de erro deve ser a esperada.'
            );
        }
        Test.stopTest();
    }
}