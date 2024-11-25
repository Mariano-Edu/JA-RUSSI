@isTest
public class TabelaComissaoServiceTest {

    @testSetup
    static void setupTestData() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        Empreendimento__c empreendimento01 = TestDataFactory.gerarEmpreendimento();
        insert empreendimento01;

        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        TabelaVendas__c tabelaVendas01 = TestDataFactory.gerarTabelaVendas();
        tabelaVendas01.Name = 'Teste02';
        insert tabelaVendas01;

        TabelaComissao__c tabelaComissaoHouse = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas.Id, empreendimento.Id);
        tabelaComissaoHouse.EmpresaVenda__c = 'House';
        insert tabelaComissaoHouse;

        TabelaComissao__c tabelaComissaoOutraEmpresa = TestDataFactory.gerarTabelaComissaoAtivada(tabelaVendas01.Id, empreendimento01.Id);
        tabelaComissaoOutraEmpresa.EmpresaVenda__c = 'Parceiro';
        insert tabelaComissaoOutraEmpresa;
    }

    @isTest
    static void testGetTabelasComissaoForHouse() {
        TabelaVendas__c tabelaVendas = [SELECT Id FROM TabelaVendas__c][1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        TabelaComissao__c tabelaComissaoHouse = [
            SELECT Id FROM TabelaComissao__c 
            WHERE EmpresaVenda__c = 'House' AND Ativa__c = true LIMIT 1
        ];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoService.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'House'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa para "House".');
        Assert.areEqual(tabelaComissaoHouse.Id, resultados[0].Id, 'A tabela de comissão retornada deve ser a da empresa "House".');
    }

    @isTest
    static void testGetTabelasComissaoForSpecificCompany() {
        TabelaVendas__c tabelaVendas = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c][1];
        
        TabelaComissao__c tabelaComissaoOutraEmpresa = [
            SELECT Id FROM TabelaComissao__c 
            WHERE EmpresaVenda__c = 'Parceiro' AND Ativa__c = true LIMIT 1
        ];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoService.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'Parceiro'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa para a empresa "OtherCompany".');
        Assert.areEqual(tabelaComissaoOutraEmpresa.Id, resultados[0].Id, 'A tabela de comissão retornada deve ser a da empresa "OtherCompany".');
    }

    @isTest
    static void testGetTabelasComissaoForEmptyParceiro() {
        TabelaVendas__c tabelaVendas = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        
        TabelaComissao__c tabelaComissaoOutraEmpresa = [
            SELECT Id FROM TabelaComissao__c 
            WHERE EmpresaVenda__c = 'House' AND Ativa__c = true LIMIT 1
        ];

        Test.startTest();
        List<TabelaComissao__c> resultados = TabelaComissaoService.getTabelasComissao(
            tabelaVendas.Id, 
            empreendimento.Id, 
            'Parceiro'
        );
        Test.stopTest();

        Assert.areEqual(1, resultados.size(), 'Deve retornar apenas uma tabela de comissão ativa para a empresa "OtherCompany".');
        Assert.areEqual(tabelaComissaoOutraEmpresa.Id, resultados[0].Id, 'A tabela de comissão retornada deve ser a da empresa "OtherCompany".');
    }
}