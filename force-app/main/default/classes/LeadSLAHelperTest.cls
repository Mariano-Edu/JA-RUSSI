@isTest
public class LeadSLAHelperTest {

    @testSetup
    static void setup() {
        // Criando grupo e filas de teste
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Group testGroup = new Group(Name = 'rock', Type = 'Queue');
            insert testGroup;
            insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
        }

        // Inserindo configurações de negócio (SLA)
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 4,  // Definindo SLA como 4 minutos
                Fase__c = 'Contacting',
                tempoLimiteParaFarolAmarelo__c = -719,
                tempoLimiteParaFarolVermelho__c = -721,
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        // Criando Lead com configuração de SLA associada
        Lead lead = new Lead(
            LastName = 'Teste',
            Description = 'Teste Lead',
            Status = 'Contacting',  // Status compatível com a configuração de SLA
            Email = 'teste@email.com',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18845-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-6789',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Instagram',
            ConfiguracaoDeSLA__c = configs[0].Id // Associando SLA
        );
        insert lead;

        // Criando Task associada ao Lead
        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id,
            ActivityDate = Date.today().addDays(1)  // Definindo data de atividade no futuro
        );
        insert task;

        // Criando Event associada ao Lead
        Event event = new Event(
            Subject = 'Teste Evento',
            ActivityDate = Date.today().addDays(1),
            DurationInMinutes = 60,
            ActivityDateTime = Datetime.now(),
            WhoId = lead.Id
        );
        insert event;
    }

    @isTest
    static void testValidateEventDate() {
        // Recuperando o evento e os leads
        List<Event> events = [SELECT Id, WhoId, EndDateTime FROM Event LIMIT 1];
        List<Id> leadIds = new List<Id>();
        for (Event event : events) {
            leadIds.add(event.WhoId);
        }

        // Verificando se o Lead e a Configuração de SLA estão corretos
        Lead lead = [SELECT Id, DataHoraVencimento__c, ConfiguracaoDeSLA__r.TempoDeSLA__c FROM Lead WHERE Id IN :leadIds LIMIT 1];
        System.assertNotEquals(null, lead, 'Lead não deve ser nulo');
        System.assertNotEquals(null, lead.ConfiguracaoDeSLA__r, 'Configuração de SLA não deve ser nula');
        System.assertNotEquals(null, lead.ConfiguracaoDeSLA__r.TempoDeSLA__c, 'TempoDeSLA__c não deve ser nulo');

        // Iniciando o teste
        Test.startTest();
        LeadSLAHelper.validateEventDate(events);
        Test.stopTest();

        // Verificando se a DataHoraVencimento foi atualizada corretamente
        lead = [SELECT Id, DataHoraVencimento__c, ConfiguracaoDeSLA__r.TempoDeSLA__c FROM Lead WHERE Id = :lead.Id];
        Datetime expectedDataHoraVencimento = events[0].EndDateTime.addMinutes((Integer) lead.ConfiguracaoDeSLA__r.TempoDeSLA__c);
        System.assertEquals(expectedDataHoraVencimento, lead.DataHoraVencimento__c, 'DataHoraVencimento__c deve ser atualizada corretamente com base na data de término do evento e SLA');
    }

    @isTest
    static void testValidateTaskDate() {
        // Recuperando a Task e os Leads associados
        Task task = [SELECT Id, WhoId, ActivityDate FROM Task LIMIT 1];

        // Iniciando o teste
        Test.startTest();
        LeadSLAHelper.validateTaskDate(new List<Task>{task});
        Test.stopTest();

        // Recuperando o Lead e verificando a atualização da DataHoraVencimento
        Lead lead = [SELECT DataHoraVencimento__c, ConfiguracaoDeSLA__r.TempoDeSLA__c FROM Lead WHERE Id = :task.WhoId LIMIT 1];
        System.assertNotEquals(null, lead, 'Lead não deve ser nulo');
        System.assertNotEquals(null, lead.ConfiguracaoDeSLA__r, 'Configuração de SLA não deve ser nula');
        System.assertNotEquals(null, lead.ConfiguracaoDeSLA__r.TempoDeSLA__c, 'TempoDeSLA__c não deve ser nulo');

        // Verificando a DataHoraVencimento esperada
        Datetime expectedDataHoraVencimento = Datetime.newInstance(
            task.ActivityDate.year(),
            task.ActivityDate.month(),
            task.ActivityDate.day()
        ).addMinutes((Integer) lead.ConfiguracaoDeSLA__r.TempoDeSLA__c);

        // Validando se a DataHoraVencimento foi atualizada corretamente
        System.assertEquals(expectedDataHoraVencimento, lead.DataHoraVencimento__c, 'DataHoraVencimento__c deve ser atualizada corretamente com base na atividade da Task e configuração de SLA');
    }
}