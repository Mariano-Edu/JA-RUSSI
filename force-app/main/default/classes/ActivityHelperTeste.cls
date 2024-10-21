@isTest
public class ActivityHelperTeste {
    
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        Empreendimento__c empreendimento = new Empreendimento__c (
            Name = 'Empreendimento Teste',
            CNPJ__c = '42318254000100'
        );

        insert empreendimento;
        
        Lead lead = new Lead(
            LastName = 'Zika',
            Company = 'Chave',
            Email = 'teste@email.com',
            LeadSource = 'Outros',
            MidiaAtual__c = 'Facebook Ads',
            CPF__c = '10020030088',
            EmpreendimentoInteresse__c = empreendimento.Id
        );


        insert lead;

        insert new List<Task> {
            new Task(
                Subject = 'Call',
                Status = 'Completed',
                WhoId = lead.Id,
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                Status = 'Not Started',
                WhoId = lead.Id,
                ActivityDate = Date.today().addDays(1)
            )
        };

        insert new Event(
            Subject = 'Teste',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            ActivityDateTime = Datetime.now(),
            WhoId = lead.Id
        );
    }

    @IsTest
    private static void updateTotalLeadActivitiesTest(){
        List<SObject> activities = new List<SObject>();
        activities.add([SELECT Id, WhoId FROM Event].get(0));
        activities.add([SELECT Id, WhoId FROM Task].get(0));

        Test.startTest();
        ActivityHelper.updateTotalLeadActivities(activities);
        Test.stopTest();

        Lead lead = [SELECT Id, TotalDeAtividadesFaseAtual__c FROM Lead].get(0);
        Assert.isTrue(lead.TotalDeAtividadesFaseAtual__c == 3, 'O lead deve ter três atividades no contador');
    }

    @isTest
    private static void getActivitiesByWhoIdMapTest() {
        Id idLead = [SELECT Id FROM Lead LIMIT 1].Id;

        List<Task> tasks = [SELECT WhoId FROM Task WHERE WhoId = :idLead];
        List<Event> events = [SELECT WhoId FROM Event WHERE WhoId = :idLead];

        Map<Id,List<SObject>> expectedTaskMap = new Map<Id,List<SObject>>();
        expectedTaskMap.put(idLead, tasks);

        Map<Id,List<SObject>> expectedEventMap = new Map<Id,List<SObject>>();
        expectedEventMap.put(idLead, events);

        Test.startTest();
            Map<Id,List<SObject>> actualTaskMap = ActivityHelper.getActivitiesByWhoIdMap(tasks);
            Map<Id, List<SObject>> actualEventMap = ActivityHelper.getActivitiesByWhoIdMap(events);
        Test.stopTest();

        Assert.areEqual(expectedEventMap.get(idLead), actualEventMap.get(idLead));
        Assert.areEqual(expectedTaskMap.get(idLead), actualTaskMap.get(idLead));
    }
}