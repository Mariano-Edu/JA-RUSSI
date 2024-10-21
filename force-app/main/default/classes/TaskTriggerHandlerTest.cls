@isTest
public class TaskTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){

        // Criando o lead com valores únicos para evitar duplicatas
        Lead lead = new Lead(
            LastName = 'Teste',
            Company = 'Teste',
            Description = 'Teste',
            CNPJ__c = '12345678000109', // Usando CNPJ único
            Email = 'unique_lead@example.com', // Usando Email único
            MidiaAtual__c = 'Youtube', // Preenchendo o campo Mídia Atual
            LeadSource = 'Web', // Preenchendo o campo Origem do Lead
            Phone = '39685-8587',
            DDDTelefone__c = '11',
            DDITelefone__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '98552-3636',
            DDICelular__c = 'Brasil (+55)'
        );

        insert lead;

        insert new List<Task>{
            new Task(
                Subject = 'E-mail',
                WhoId = lead.Id,
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'WhatsApp',
                WhoId = lead.Id,
                Status = 'Open',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                WhoId = lead.Id,
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Call',
                WhoId = lead.Id,
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(1)
            )
        };
    }

    @IsTest
    private static void beforeUpdateTest(){
        Test.startTest();
        
        Task task = [SELECT Id, WhoId, ActivityDate FROM Task LIMIT 1];
        task.ActivityDate = Date.today().addDays(1);
        update task;

        Test.stopTest();
    }

    @IsTest
    private static void afterDeleteTest(){
        Test.startTest();
        Task task = [SELECT Id, WhoId, ActivityDate FROM Task WHERE Status = 'Completed' LIMIT 1];
        delete task;
        Test.stopTest();
    }
}