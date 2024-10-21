@isTest
public class LeadTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    @isTest
    private static void beforeUpdateTest(){
        List<Lead> leads = [SELECT Id, Status, LeadSource FROM Lead];
        leads.get(2).Status = 'Qualified';

        insert new List<Task> {
            new Task(
                Subject = 'WhatsApp',
                Status = 'Completed',
                WhoId = leads.get(2).Id,
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'WhatsApp',
                Status = 'Not Started',
                WhoId = leads.get(2).Id,
                ActivityDate = Date.today().addDays(1)
            )
        };
        
        Test.startTest();
        update leads;
        Test.stopTest();

        Assert.isFalse(leads.get(0).hasErrors());
        Assert.isFalse(leads.get(1).hasErrors());
        Assert.isFalse(leads.get(2).hasErrors());
    }

    private static void doCreateData(){
        List<Lead> leads = new List<Lead>{
            new Lead(
                LastName = 'Teste',
                Company = 'Teste',
                Description = 'Teste',
                Email = 'teste@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '14',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '14',
                Celular__c = '18845-6789',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                Status = 'New'
            ),
            new Lead(
                LastName = 'Teste',
                Company = 'Teste',
                Description = 'Teste',
                Email = 'teste2@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '15',
                Phone = '18835-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '15',
                Celular__c = '18835-6789',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                Status = 'Converted'
            ),
            new Lead(
                LastName = 'Teste',
                Company = 'Teste',
                Description = 'Teste',
                Email = 'teste3@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18855-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18855-6789',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                Status = 'Scheduled'
            )
        };

        
        insert leads;
        
        Event event = new Event(
            Subject='Teste',
            ActivityDate=Date.today(),
            DurationInMinutes=60,
            ActivityDateTime=Datetime.now(),
            WhoId=leads.get(2).Id,
            StatusVisita__c = 'Done'
        );

        insert event;
    }
}