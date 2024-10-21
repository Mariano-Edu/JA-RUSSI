@isTest
private class LeadAPIHelperTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        Empreendimento__c empreendimentoTeste = new Empreendimento__c(
        Name = 'EmpreendimentoTeste',
        CNPJ__c = '21268544000109'
        );

        insert empreendimentoTeste;

        Lead lead01 = new Lead (
        LastName = 'TesteSetup',
        Email= 'testeSetup@gmail.com',
        DDITelefone__c = 'Brasil (+55)',
        DDDTelefone__c = '12',
        Phone = '2586-2013',
        Status = 'New',
        MidiaAtual__c = 'Instagram',
        LeadSource = 'Instagram',
        EmpreendimentoInteresse__c = empreendimentoTeste.Id
        );

        insert lead01;

        insert new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reiteração').getRecordTypeId(),
            WhoId = lead01.Id,
            Subject = 'Reiteração',
            Status = 'Open',
            Email__c = lead01.Email,
            Nome__c = lead01.LastName,
            OrigemLead__c = lead01.LeadSource,
            Midia__c = lead01.MidiaOriginal__c,
            DataHoraInteracao__c = Datetime.now(),
            Celular__c = lead01.Celular__c,
            EmpreendimentoInteresse__c = lead01.EmpreendimentoInteresse__c,
            ActivityDate = Date.today().addDays(1)
        );
    }


    @IsTest
    static void handleReiterationTest(){
        Map<Id, Lead> mapNewLeads = new Map<Id, Lead>();

        List<Lead> leadsJaInseridos = [Select Id, LastName, OwnerId, Email, Celular__c, Phone, EmpreendimentoInteresse__c, PrimeiroEmpreendimento__c, PrimeiroEmpreendimento__r.Name, Status, LeadSource, MidiaOriginal__c from Lead LIMIT 1];

        Empreendimento__c  empreendimento = [Select Id FROM Empreendimento__c LIMIT 1];

        Lead leadNovoReiteracao = new Lead (
        LastName = 'TesteSetupo',
        Company = 'TesteCompanySetupo',
        MidiaAtual__c = 'Instagram',
        LeadSource = 'Google Ads',
        Email= 'testesetupo@gmail.com',
        DDITelefone__c = 'Brasil (+55)',
        DDDTelefone__c = '12',
        Phone = '5586-2013',
        Status = 'New',
        EmpreendimentoInteresse__c = empreendimento.Id
        );

        leadNovoReiteracao.Id = leadsJaInseridos.get(0).Id;

        mapNewLeads.put(leadsJaInseridos[0].Id, leadNovoReiteracao);

        Test.startTest();
        LeadAPIHelper.handleReiteration(mapNewLeads);
        Test.stopTest();

        List<Lead> leadsJaInseridosPosUpdate = [Select Id, LastName, OwnerId, Email, Celular__c, Phone, EmpreendimentoInteresse__c, PrimeiroEmpreendimento__c, PrimeiroEmpreendimento__r.Name, Status, LeadSource, MidiaOriginal__c from Lead LIMIT 1];

        system.assertEquals(leadsJaInseridosPosUpdate[0].LastName, leadNovoReiteracao.LastName);
        system.assertEquals(leadsJaInseridosPosUpdate[0].Email, leadNovoReiteracao.Email);
        system.assertEquals(leadsJaInseridosPosUpdate[0].Celular__c, leadNovoReiteracao.Celular__c);
        system.assertEquals(leadsJaInseridosPosUpdate[0].Phone, leadNovoReiteracao.Phone);
        system.assertEquals(leadsJaInseridosPosUpdate[0].EmpreendimentoInteresse__c, leadNovoReiteracao.EmpreendimentoInteresse__c);
        system.assertEquals(leadsJaInseridosPosUpdate[0].LeadSource, leadNovoReiteracao.LeadSource);
    }
}