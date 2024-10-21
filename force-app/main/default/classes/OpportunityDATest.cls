@isTest
private class OpportunityDATest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }
    
    private static void doCreateData() {

        // Criando a Account com campos obrigatórios
        Account account = new Account(
            Name = 'Account',
            CNPJ__c = '10155540000106',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '12',
            Celular__c = '12345-7789',   
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '12345-6789'   
        );
        
        insert account;

        // Criando o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '10155540000106'
        );

        insert empreendimento;

        // Criando o Bloco
        Bloco__c bloco = new Bloco__c(
            Name = 'Torre A',
            Empreendimento__c = empreendimento.Id
        );

        insert bloco;

        // Criando o Produto (Unidade)
        Product2 unidade1 = new Product2(
            Name = 'Unidade 1',
            Bloco__c = bloco.Id,
            NumeroDaUnidade__c = 1
        );

        Product2 unidade2 = new Product2(
            Name = 'Unidade 2',
            Bloco__c = bloco.Id,
            NumeroDaUnidade__c = 2
        );

        insert new List<Product2>{unidade1, unidade2};

        // Criando as oportunidades associadas (uma para cada unidade)
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Oportunidade 1',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(1),
                AccountId = account.Id,   // Associando à Account
                Unidade__c = unidade1.Id   // Associando à Unidade 1
            ),
            new Opportunity(
                Name = 'Oportunidade 2',
                StageName = 'Proposta',
                CloseDate = System.today().addMonths(2),
                AccountId = account.Id,
                Unidade__c = unidade2.Id
            )
        };

        insert opportunities;
    }

    @isTest
    public static void getOpportunityByAccountProductTest() {
        // Consultando o produto e a conta criados no TestSetup
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'Unidade 1' LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        // Testando a função OpportunityDA.getOpportunityByAccountProduct
        List<Opportunity> opps = OpportunityDA.getOpportunityByAccountProduct(account.Id, produto.Id, null, null);
        
        // Debug para verificar o número de oportunidades retornadas
        System.debug('Número de oportunidades retornadas: ' + opps.size());

        // Verificando se o tamanho da lista é 1 (apenas 1 oportunidade com a Unidade 1)
        Assert.isTrue(opps.size() == 1, 'Esperava 1 oportunidade, mas foi retornado: ' + opps.size());
    }
}