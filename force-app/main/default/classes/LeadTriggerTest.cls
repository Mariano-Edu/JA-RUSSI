@isTest
public class LeadTriggerTest {
    
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento',
            CNPJ__c = '32339125000137'
        );

        insert empreendimento;

        List<Lead> leads = new List<Lead>{
            new Lead(
                    LastName = 'Teste',
                    Company = 'Teste',
                    Email = 'teste@email.com',
                    MidiaAtual__c = 'Instagram',
                    LeadSource = 'Instagram',
                    Status = 'New',
                    DDICelular__c = null,
                    DDITelefone__c = null
                ),

                new Lead(
                    LastName = 'Teste',
                    Company = 'Teste',
                    Email = 'teste2@email.com',
                    MidiaAtual__c = 'Instagram',
                    LeadSource = 'Instagram',
                    Status = 'Scheduled',
                    DDICelular__c = null,
                    DDITelefone__c = null
                ),

                new Lead(
                    LastName = 'Teste',
                    Company = 'Teste',
                    Email = 'teste3@email.com',
                    MidiaAtual__c = 'Instagram',
                    LeadSource = 'Instagram',
                    CPF__c = '10020030088',
                    EmpreendimentoInteresse__c = empreendimento.Id,
                    Status = 'New',
                    DDICelular__c = null,
                    DDITelefone__c = null
                )
        };

        insert leads;

        Event event = new Event(
            Subject = 'Teste',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            ActivityDateTime = Datetime.now(),
            WhoId = leads.get(1).Id,
            StatusVisita__c = 'Done'
        );

        insert event;

        insert new List<Task> {
            new Task(
                Subject = 'Call',
                Status = 'Completed',
                WhoId = leads.get(1).Id,
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                Status = 'Not Started',
                WhoId = leads.get(1).Id,
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                Status = 'Completed',
                WhoId = leads.get(2).Id,
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                Status = 'Not Started',
                WhoId = leads.get(2).Id,
                ActivityDate = Date.today().addDays(1)
            )
        };
    }
    
    @isTest
    public static void beforeUpdateTest(){
        List<Lead> leads = [SELECT Id, Status FROM Lead];

        leads.get(1).Status = 'Qualified';

        Test.startTest();
        TriggerHandler.bypass('LeadTriggerHandler');
        update leads;
        TriggerHandler.clearBypass('LeadTriggerHandler');
        Test.stopTest();

        Assert.isFalse(leads.get(0).hasErrors());
        Assert.isFalse(leads.get(1).hasErrors());
        Assert.isFalse(leads.get(2).hasErrors());
    }
}