@isTest
public class TaskHelperTest {
    
    @TestSetup
    static void makeData(){
        doCreateData();
    }
    
    private static void doCreateData() {

        insert new ConfiguracoesDeNegocio__c(
            // 1.440 minutos(um dia)
            TempoDeSla__c = 1440,
            Fase__c = 'New'
        );

        Lead lead = new Lead(
            LastName = 'teste1',
            Company = 'Chave',
            Email = 'e@e.com',
            DDDCelular__c = '11',
            DDICelular__c = 'Afeganistão (+93)',
            Celular__c = '12345-6789',
            DDDTelefone__c = '78',
            DDITelefone__c = 'Afeganistão (+93)',
            Phone = '12345-6789',
            MidiaAtual__c = 'Youtube', 
            LeadSource = 'Web' 
        );

        insert lead;
    }

    @isTest
    private static void updateReiterationCounterTest() {
        Lead lead = [SELECT Id FROM Lead].get(0);
    
        List<Task> tasks = new List<Task> {
            new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            )
        };
    
        Test.startTest();
        insert tasks;
        Test.stopTest();
    
        Lead leadUpdated = [SELECT QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(leadUpdated.QuantidadeDeReiteracoes__c, 1, 'Quantidade de reiterações deve ser igual a 1');
    }

    @isTest
    private static void handleAfterInsertDeleteTest() {
        Lead lead = new Lead(
            LastName = 'Lead Task Test',
            Email = 'teste@email.com',
            MidiaAtual__c = 'Instagram', 
            LeadSource = 'Web'
        );

        insert lead;

        List<Task> tasks = new List<Task> {
            new Task(
                WhoId = lead.Id,
                Subject = 'Call',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'E-mail',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'WhatsApp',
                Status = 'Open',
                ActivityDate = Date.today().addDays(1)
            )
        };

        insert tasks;

        Test.startTest();

        Task taskInsert = new Task(
            WhoId = lead.Id,
            Subject = 'WhatsApp',
            Status = 'Open',
            ActivityDate = Date.today().addDays(1)
        );
        
        // Database.SaveResult resultInsertFail = Database.insert(taskInsert, false);
        // Assert.isFalse(resultInsertFail.isSuccess(), 'Não é possível criar uma tarefa de contato quando já possui uma tarefa em aberto');

        tasks[2].Status = 'Completed';
        update tasks;
        
        Database.SaveResult resultInsertSuccess = Database.insert(taskInsert, false);
        Assert.isTrue(resultInsertSuccess.isSuccess(), 'Deve ser possível criar uma tarefa quando não há tarefas em aberto');
        
        Lead leadUpdated = [SELECT ControleCadencia__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual('4° Tentativa', leadUpdated.ControleCadencia__c, 'Controle de Cadência deve ser 4° Tentativa');

        delete tasks;
        Lead leadTaskDeleted = [SELECT ControleCadencia__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual('1° Tentativa',leadTaskDeleted.ControleCadencia__c, 'Controle de Cadência deve ser 1° Tentativa');
        Assert.areEqual([SELECT Id FROM Task WHERE WhoId = :lead.Id].size(), 1, 'Deve haver 1 task com este WhoId');
        
        Test.stopTest();
    }

    @isTest
    private static void updateReiterationCounterMultipleTest() {
        Lead lead = [SELECT Id FROM Lead].get(0);
    
        List<Task> tasks = new List<Task> {
            new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(1)
            )
        };
    
        Test.startTest();
        insert tasks;
        Test.stopTest();
    
        Lead leadUpdated = [SELECT QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(2, leadUpdated.QuantidadeDeReiteracoes__c, 'Quantidade de Reiterações deve ser 2');
    }

    @isTest
    private static void countContactsTasksTest() {
        Lead lead = new Lead(
            LastName = 'Lead Task Test',
            Email = 'test2@email.com',
            MidiaAtual__c = 'Instagram', 
            LeadSource = 'Web'
        );

        insert lead;

        List<Task> tasks = new List<Task> {
            new Task(
                WhoId = lead.Id,
                Subject = 'Call',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'E-mail',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'WhatsApp',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            ),
            new Task(
                WhoId = lead.Id,
                Subject = 'WhatsApp',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            )
        };

        insert tasks;

        Test.startTest();

        Lead leadContacting = [SELECT Status FROM Lead WHERE Email = 'test2@email.com' LIMIT 1];
        Assert.areNotEqual('Lost', leadContacting.Status, 'O status do lead deve ser diferente de Lost');

        insert new Task(
            WhoId = lead.Id,
            Subject = 'WhatsApp',
            Status = 'Open',
            ActivityDate = Date.today().addDays(1)
        );

        Lead leadLost = [SELECT Status FROM Lead WHERE Email = 'test2@email.com' LIMIT 1];
        Assert.areEqual('Lost', leadLost.Status, 'O status do lead deve ser Lost');
        
        Test.stopTest();
    }
}