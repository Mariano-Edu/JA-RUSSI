@isTest
public class TaskDATest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group testGroup = new Group(Name='LeadsPerdidos', Type='Queue');
        	insert testGroup;
    		insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
		}
    
        Lead lead = new Lead(
            LastName = 'Teste',
            Company = 'Teste',
            Description = 'Teste',
            CNPJ__c = '12345678000109',
            Email = 'unique_lead@example.com',
            MidiaAtual__c = 'Youtube',
            LeadSource = 'Web',
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
                Subject = 'Reiteração',
                WhoId = lead.Id,
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(1)
            )
        };
    }

    @IsTest
    private static void getTasksByWhoId(){
        Lead lead = [SELECT Id FROM Lead].get(0);
        List<Task> tasks = new List<Task>();

        Test.startTest();
        tasks = TaskDA.getTasksByWhoId(new Set<String>{'Id', 'WhoId'}, new Set<Id>{lead.Id});
        Test.stopTest();

        Assert.isTrue(tasks.size() == [SELECT COUNT() FROM Task WHERE WhoId = :lead.Id]);
    }

    @IsTest
    private static void getTasksReiteracaoNaoIniciadoByWhoIdTest() {
        Lead lead = [SELECT Id FROM Lead].get(0);
        List<Task> tasks = new List<Task>();

        Test.startTest();
        tasks = TaskDA.getTasksReiteracaoByWhoId(new Set<String>{'Id', 'WhoId'}, new Set<Id>{lead.Id});
        Test.stopTest();

        Assert.isTrue(tasks.size() == [SELECT COUNT() FROM Task WHERE WhoId = :lead.Id AND Subject = 'Reiteração' AND Status = 'Not Started']);
    }

    @IsTest
    private static void insertTasksTest() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];

        Task openTask = [SELECT Id, Status FROM Task WHERE Status = 'Open' LIMIT 1];
        openTask.status = 'Completed';
        update openTask;

        List<Task> tasks = new List<Task>{
            new Task(
                Subject = 'Teste Insert 1',
                WhoId = lead.Id,
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                Subject = 'Teste Insert 2',
                WhoId = lead.Id,
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            )
        };

        Test.startTest();
        TaskDA.insertTasks(tasks);
        Test.stopTest();

        List<Task> tasksInseridas = [SELECT Id FROM Task WHERE Subject LIKE 'Teste Insert%'];

        Assert.isTrue(tasksInseridas.size() == 2, 'Devem ser inseridas 2 tasks');
    }
}