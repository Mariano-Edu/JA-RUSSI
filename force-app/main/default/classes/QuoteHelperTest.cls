@isTest
private class QuoteHelperTest {

    @TestSetup
    static void makeData() {

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );

        update standardPricebook;

        Account acc = new Account(
            Name = 'Corretor 2',
            CNPJ__c = '35635456000102',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-0089',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '12',
            Phone = '96857-6789'   
        );

        insert acc;

        User user = new User(
            Alias = 'Diretor',
            Email = 'test2@email.com',
            EmailEncodingKey = 'ISO-8859-1',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserName = 'test300920241021z@email.com',
            profileId = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1].Id
        );

        insert user;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade 1',
            StageName = 'Proposta',
            CloseDate = System.today().addMonths(1),
            AccountId = acc.Id,
            ResponsavelPeloLead__c = user.Id
        );

        insert opp; 

        List<Quote> quotes = new List<Quote> {
            new Quote(Name = 'Test1', Status = 'Pendente', OpportunityId = opp.Id),
            new Quote(
                Name = 'Test2',
                DescontoConformeTabela__c = true,
                ComissaoConformeTabela__c = true,
                Status = 'Pendente',
                OpportunityId = opp.Id
            )
        };
        
        insert quotes;
    }

    @isTest
    private static void handleAfterUpdateTest() {
        List<Quote> quotes = [SELECT Status FROM Quote];

        for(Quote iQuote : quotes) {
            iQuote.Status = 'Em Aprovação';
            iQuote.PrecoLista__c = 0.0;
        }

        Test.startTest();
        update quotes;
        Test.stopTest();

        List<ProcessInstance> pedidosAprovacao = [
            SELECT 
                Id,
                TargetObjectId
            FROM ProcessInstance 
            WHERE Status = 'Pending'
        ];


        Assert.isTrue(pedidosAprovacao.size() == 1);
        Assert.areEqual(pedidosAprovacao.get(0).TargetObjectId, quotes.get(0).Id);
    }
}