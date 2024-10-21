@isTest
public class LeadSLAHelperTest {
    
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
                TempoDeSla__c = 1440,
                Fase__c = 'Contacting',
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        DateTime dataHoraVencida = DateTime.now().addDays(-1);

        Lead lead = new Lead(
            LastName = 'Teste',
            Description = 'Teste',
            Status = 'Novo',
            Email = 'teste@email.com',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Instagram',
            ConfiguracaoDeSLA__c = configs.get(0).Id
            
        );
        insert lead;

        System.debug(JSON.serialize([SELECT Id, DataHoraVencimento__c, Vencido__c FROM Lead]));

        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id,
            ActivityDate = Date.today().addDays(1)
        );
        insert task;
    }
    
    @isTest
    static void testLeadVencidoSchedule() {
        List<Lead> lstLead = [SELECT Id, Status, Vencido__c FROM Lead];
        
        Test.startTest();
      	LeadSLAHelper.verifyLeadControlSLA(lstLead, null);
        Test.stopTest();

        System.assertEquals(true, lstLead[0].DataHoraVencimento__c != null);

    }
}