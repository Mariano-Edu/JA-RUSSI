@isTest
public class LeadVencidoBatchTest {
    
    @testSetup
    static void setup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group testGroup = new Group(Name='rock', Type='Queue');
        	insert testGroup;
    		insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
		}
        
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                // 1.440 minutos(um dia)
                TempoDeSla__c = -5,
                Fase__c = 'Contacting',
                tempoLimiteParaFarolAmarelo__c = -3,
                tempoLimiteParaFarolVermelho__c = -2,
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        Lead lead = new Lead(
            FirstName = 'teeste',
            LastName = 'Teste',
            Email = 'testsla@test.com',
            Description = 'Teste',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = configs.get(0).Id,
            DataHoraVencimento__c = DateTime.now().addDays(-1),
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Instagram'
        );
        insert lead;

        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id,
            ActivityDate = Date.today()
        );
        insert task;
    }

    @isTest
    static void atualizaLeadVencido() {
        Test.startTest();
        LeadVencidoBatch batch = new LeadVencidoBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<Lead> leadsAfterTest = [SELECT Id, Status FROM Lead WHERE Status = 'Lost'];
        System.assert(!leadsAfterTest.isEmpty());
        
    }
}