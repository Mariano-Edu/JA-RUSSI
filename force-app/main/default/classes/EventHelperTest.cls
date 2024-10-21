@isTest
private class EventHelperTest {
    @TestSetup
    static void makeData() {
        doMakeData();
    }

    private static void doMakeData(){
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJ__c = '21268544000109';
        
        insert empreendimento;

        List<Lead> leads = new List<Lead>{
            new Lead(
                LastName = 'teste1',
                Company = 'Chave',
                Email = 'e@e.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                CPF__c = '87657837861',
                LeadSource = 'Outros',
                FaixaInvestimento__c = 'R$ 300 Mil a R$ 999 Mil',
                Status = 'Scheduled',
                MidiaAtual__c = 'Facebook Ads',
                EmpreendimentoInteresse__c = empreendimento.Id
            ),

            new Lead(
                LastName = 'teste1',
                Company = 'Chave',
                Email = 'e@4.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '28845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '28845-6789',
                LeadSource = 'Outros',
                CPF__c = '41445446723',
                Status = 'Scheduled',
                MidiaAtual__c = 'Facebook Ads',
                FaixaInvestimento__c = 'R$ 300 Mil a R$ 999 Mil',
                EmpreendimentoInteresse__c = empreendimento.Id
            ),
            
            new Lead(
                LastName = 'teste fail',
                Company = 'dhrefjikdoc',
                LeadSource = 'Outros',
                MidiaAtual__c = 'Facebook Ads',
                Email = 'e@ase.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '38845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '38845-6789',
                CPF__c = '51273233204'
            )
        };
     
        TriggerHandler.bypass('LeadTriggerHandler');
        insert leads;
        TriggerHandler.clearBypass('LeadTriggerHandler');

        Account contaPF = new Account(
            FirstName = 'Conta',
            LastName = 'PF',
            PersonEmail = 'conta@teste.com'
        );
        insert contaPF;
        
        insert new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Proposta',
            CloseDate = Date.today().addDays(30),
            AccountId = contaPF.Id
        );
    }   

    @isTest
    private static void validateEventLookupTest(){
        List<Lead> leads = [SELECT Id FROM Lead];
        Id oppId = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade Teste' LIMIT 1].id;

        List<Event> events = new List<Event>{
            new Event(
                WhoId = leads[0].Id,
                Type = 'Visita',
                Subject = 'E-mail',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now()
            ),

            new Event(
                WhoId = leads[1].Id,
                Type = 'Visita',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now()
            ),

            new Event(
                WhoId = leads[2].Id,
                Type = 'Visita',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now()
            ),

            new Event(
                Subject = 'Visita',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now().addDays(15),
                WhatId = oppId
            ),

            new Event(
                Subject = 'Reunião online',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now().addDays(15),
                WhatId = oppId
            ),

            new Event(
                Subject = 'Reunião Presencial',
                StatusVisita__c = 'Done',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now().addDays(15),
                WhatId = oppId
            )
        };
    
        Test.startTest();
            EventHelper.validateEventLookup(events);
        Test.stopTest();

        Assert.isNotNull(events[0].EmpreendimentoInteresse__c);
        Assert.isNotNull(events[1].EmpreendimentoInteresse__c);
        Assert.isNull(events[2].EmpreendimentoInteresse__c);

        Assert.areNotEqual(events[0].Subject, events[0].Type);
    }
}