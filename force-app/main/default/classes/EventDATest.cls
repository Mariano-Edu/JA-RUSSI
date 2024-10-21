@isTest
public class EventDATest {

    @TestSetup
    private static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        // Criando um registro de Empreendimento com mais campos relevantes
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '12345678000195', // CNPJ válido
            Bairro__c = 'Centro',
            CEP__c = '01001-000',
            Cidade__c = 'São Paulo',
            UF__c = 'SP',
            Logradouro__c = 'Rua Teste',
            DataInicioPlanejada__c = Date.today(), // Data de início planejada
            DataConclusaoPlanejada__c = Date.today().addMonths(12), // Data de conclusão planejada
            Ativo__c = true // Empreendimento ativo
        );
        insert empreendimento;

        Lead lead = new Lead(
            LastName = 'Teste',
            Company = 'Teste',
            Description = 'Teste',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18845-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-6789',
            Email = 'Example@email.com',
            Status = 'Scheduled',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Instagram',
            CPF__c = '12345678909', // Usando um CPF válido
            CNPJ__c = '12345678000195', // Preenchendo o campo CNPJ
            EmpreendimentoInteresse__c = empreendimento.Id // Usando o ID do Empreendimento criado
        );
        insert lead;

        List<Event> events = new List<Event>{
            new Event(
                Subject = 'Teste',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = lead.Id,
                StatusVisita__c = 'Done'
            ),
            new Event(
                Subject = 'Teste',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = lead.Id
            )
        };

        insert events;
    }

    @isTest
    private static void getEventDoneByWhoIdTest() {
        Test.startTest();

        List<Lead> leads = [SELECT Id FROM Lead];
        List<Event> events = EventDA.getEventDoneByWhoId(
            new Set<String>{'Id'},
            new Set<Id>{leads.get(0).Id}
        );

        Test.stopTest();
        Assert.isTrue(events.size() == 1, 'Deve haver um evento com status "Done".');
    }

    @isTest
    private static void getEventByWhoIdTest() {
        Lead lead = [SELECT Id FROM Lead].get(0);
        List<Event> events = new List<Event>();

        Test.startTest();
        events = EventDA.getEventByWhoId(
            new Set<String>{'Id', 'WhoId'},
            new Set<Id>{lead.Id}
        );
        Test.stopTest();

        Assert.isTrue(events.size() == 2, 'Deve haver dois eventos associados ao Lead.');
    }
}