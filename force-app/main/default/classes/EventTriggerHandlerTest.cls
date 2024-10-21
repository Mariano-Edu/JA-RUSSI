@isTest
public class EventTriggerHandlerTest {
    @TestSetup
    static void makeData() {
        doCreateData();
    }  

    private static void doCreateData() {
        // Criando um Empreendimento para associar ao Lead
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '12345678000195' // CNPJ válido
        );
        insert empreendimento;

        // Criando o Lead com os campos obrigatórios CPF/CNPJ e Empreendimento preenchidos
        List<Lead> leads = new List<Lead> {
            new Lead(
                LastName = 'Teste',
                Company = 'Teste',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                Status = 'Scheduled',
                TotalDeAtividadesFaseAtual__c = 0,
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                CPF__c = '12345678909', // Preenchendo o campo CPF válido
                EmpreendimentoInteresse__c = empreendimento.Id // Associando o Lead a um Empreendimento
            )
        };

        insert leads;
    }

    @isTest
    public static void validateEventLookupTest() {
        Lead scheduledLead = [SELECT Id FROM Lead].get(0);

        Event event = new Event(
            Subject = 'Teste',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            ActivityDateTime = Datetime.now(),
            WhoId = scheduledLead.Id
        );

        Test.startTest();
        insert event;
        Test.stopTest();

        Assert.isFalse(event.hasErrors());
    }

    @IsTest
    private static void afterDeleteTest() {
        Lead lead = [SELECT Id, TotalDeAtividadesFaseAtual__c FROM Lead].get(0);

        Event events = new Event(
            Subject = 'Teste',
            ActivityDate = Date.today(),
            DurationInMinutes = 60,
            ActivityDateTime = Datetime.now(),
            WhoId = lead.Id
        );

        Test.startTest();
        insert events;
        delete events;
        Test.stopTest();

        System.debug(lead.TotalDeAtividadesFaseAtual__c);
        Assert.isTrue(lead.TotalDeAtividadesFaseAtual__c == 0);
    }
}