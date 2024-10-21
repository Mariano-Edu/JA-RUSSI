@isTest
private class ProdutoSelectorTest {
    
    @TestSetup
    static void makeData() {
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

        insert new List<Product2> {
            new Product2(
                Name = 'Unidade',
                Bloco__c = bloco.Id,
                NumeroDaUnidade__c = 1,
                Empreendimento__c = empreendimento.Id
            ),
            new Product2(
                Name = 'Unidade1',
                Bloco__c = bloco.Id,
                NumeroDaUnidade__c = 2,
                Empreendimento__c = empreendimento.Id
            )
        };
    }


    @isTest
    private static void getProdutosByIdTest() {
        Id idUnidade = [SELECT Id FROM Product2 LIMIT 1].Id;

        Test.startTest();
        Product2 unidade = ProdutoSelector.getProdutosById(idUnidade);
        Test.stopTest();

        Assert.isNotNull(unidade);
    }

    @IsTest
    private static void CoeficienteProdutoPorIdTest() {
        Map<Id,Product2> expectedMap = new Map<Id,Product2>([
            SELECT 
                Id,
                Coeficiente__c
            FROM Product2
        ]);

        Test.startTest();
        Map<Id,Product2> actualMap = ProdutoSelector.CoeficienteProdutoPorId(new List<Id>(expectedMap.keySet()));
        Test.stopTest();

        for(Id idUnidade : expectedMap.keySet()) {
            Assert.isTrue(actualMap.containsKey(idUnidade));
            Assert.areEqual(expectedMap.get(idUnidade), actualMap.get(idUnidade));
        }
    }

    @isTest
    private static void obterUnidadesRelacionadasTest() {
        Set<Id> idsEmpreendimentos = new Map<Id,Empreendimento__c>([SELECT Id FROM Empreendimento__c]).keySet();

        Map<Id,Product2> expectedMap = new Map<Id,Product2>([
            SELECT
                Id,
                Name,
                PrecoLista__c,
                Coeficiente__c,
                MetragemTotal__c,
                Empreendimento__c
            FROM Product2 
            WHERE Empreendimento__c IN :idsEmpreendimentos
        ]);

        Test.startTest();
        Map<Id,Product2> actualMap = ProdutoSelector.obterUnidadesRelacionadas(idsEmpreendimentos);
        Test.stopTest();

        for(Id idUnidade : expectedMap.keySet()) {
            Assert.isTrue(actualMap.containsKey(idUnidade));
            Assert.areEqual(expectedMap.get(idUnidade), actualMap.get(idUnidade));
        }
    }

    @isTest
    private static void getProductsDisponivelByIdEmpreendimentoTest() {
        Id idEmpreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        List<Product2> expectedList = [
            SELECT 
                Id,
                Name,
                ProductCode,
                ValorDaUnidade__c,
                Status__c,
                Andar__c,
                CorDisponivel__c,
                Bloco__r.name,
                RecordType.name,
                CorReservado__c,
                CorVendida__c,
                MetragemDaUnidadeM__c,
                NumeroDeSuites__c,
                NumeroQuartos__c,
                Empreendimento__r.Name,
                Empreendimento__r.DiasDeVencimentoDaParcela__c,
                NumeroDaUnidade__c
            FROM Product2
            WHERE 
                Status__c != '' AND
                Empreendimento__r.DisponivelNoEspelho__c = true AND
                Empreendimento__c = :idEmpreendimento
        ];

        Test.startTest();
        List<Product2> actualList = ProdutoSelector.getProductsDisponivelByIdEmpreendimento(idEmpreendimento);
        Test.stopTest();

        Assert.areEqual(expectedList, actualList);
    }
}