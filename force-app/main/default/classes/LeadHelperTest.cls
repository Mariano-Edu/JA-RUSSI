@isTest
private class LeadHelperTest {

    @TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Id idRole = [SELECT Id FROM UserRole WHERE UserRole.DeveloperName = 'Integracao'].Id;
            Id idProfile = [SELECT Id FROM Profile WHERE (Name = 'Usuário Padrão') OR (Name = 'Standard User') LIMIT 1].Id;

            insert new User(
                FirstName = 'Ricardo',
                LastName = 'Doe',
                Email = 'ricardo@testemail.com',
                Username = 'ricardo@testemail.com',
                Alias = 'rdoe',
                ProfileId = idProfile,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                UserRoleId = idRole,
                LanguageLocaleKey = 'en_US'
            );

            Group testGroup = new Group(Name='Fila perdidos', Type='Queue');
            insert testGroup;
            insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
        }

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento',
            CNPJ__c = '21268544000109'
        );

        insert empreendimento;

        Contact contact = new Contact(
            FirstName = 'John',  // Preenchendo o primeiro nome obrigatório
            LastName = 'Doe',    // Preenchendo o sobrenome obrigatório
            Email = 'john.doe@testemail.com',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Corretor'].get(0).Id
        );
        insert contact;

        insert new List<Lead>{
            new Lead(
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaFisica'].get(0).Id,
                FirstName = 'Lead', // Adicionando FirstName para atender à regra de validação
                LastName = 'Teste',
                Company = 'Chave',
                Email = 'e@e.com',  
                LeadSource = 'Outros',
                MidiaAtual__c = 'Facebook Ads',
                DDDCelular__c = '19',
                DDICelular__c = 'Afeganistão (+93)',
                Celular__c = '12345-6789',
                DDDTelefone__c = '78',
                DDITelefone__c = 'Afeganistão (+93)',
                Phone = '12345-6789',
                Status = 'Qualified'
            ),

            new Lead(
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PessoaFisica'].get(0).Id,
                LastName = 'test2',
                Company = 'Chave',
                LeadSource = 'Outros',
                MidiaAtual__c = 'Facebook Ads',
                Email = 'a@a.com',
                EmpreendimentoInteresse__c = empreendimento.Id,
                CPF__c = '70611982650',
                Corretor__c = contact.Id,
                FaixaInvestimento__c = 'R$ 300 Mil a R$ 999 Mil',
                DDDCelular__c = '11',
                DDICelular__c = 'Afeganistão (+93)',
                Celular__c = '12345-6789',
                DDDTelefone__c = '77',
                DDITelefone__c = 'Afeganistão (+93)',
                Phone = '12345-7789',
                Status = 'Qualified'
            )
        };

        insert new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 1440,
                Fase__c = 'Qualified',
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'Fila perdidos'
            ),

            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 1440,
                Fase__c = 'Scheduled',
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'Fila perdidos'
            ),

            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 1440,
                Fase__c = 'Contacting',
                FaseParaRedirecionamentoDoLead__c = 'Lost',
                FilaParaRedirecionamentoDoLead__c = 'Fila perdidos'
            )
        };

    }

    @isTest
    private static void handleUpdateValidateStatusFailTest() {
        List<Lead> leads = [
            SELECT 
                Id,
                Status, 
                EmpreendimentoInteresse__c,
                PrimeiroEmpreendimento__c,
                MidiaAtual__c,
                MidiaOriginal__c,
                LeadSource,
                PrimeiraOrigem__c,
                IsConverted,
                Owner.Id
            FROM Lead
        ];

        Map<Id,Lead> leadsMap = new Map<Id,Lead>(leads);
        Map<Id,Lead> oldLeadsMap = leadsMap.deepClone();

        leads[0].Status = 'Qualified';

        Lead leadContacting = oldLeadsMap.get(leads[0].Id);

        leadContacting.Status = 'Contacting';

        oldLeadsMap.put(leadContacting.Id, leadContacting);

        Test.startTest();
            try {
                LeadHelper.handleUpdate(leads, oldLeadsMap);
            } catch(DmlException e) {
                System.debug(e);
            }
        Test.stopTest();

        Assert.isTrue(leads[0].hasErrors());
    }

    @isTest
    private static void handleUpdateValidateStatusSuccessTest() {
        List<Lead> leads = [
            SELECT 
                Id,
                Status, 
                EmpreendimentoInteresse__c,
                PrimeiroEmpreendimento__c,
                MidiaAtual__c,
                MidiaOriginal__c,
                LeadSource,
                Owner.Id,
                ConfiguracaoDeSLA__c,
                RecordTypeId,   
                PrimeiraOrigem__c
            FROM Lead
        ];

        Map<Id,Lead> leadsMap = new Map<Id,Lead>(leads);
        Map<Id,Lead> oldLeadsMap = leadsMap.deepClone();

        Lead leadScheduling = oldLeadsMap.get(leads[1].Id);
        leadScheduling.Status = 'Scheduled';
        oldLeadsMap.put(leadScheduling.Id, leadScheduling);

        leads[0].Status = 'Scheduled';

        Test.startTest();
            insert new List<Task> {
                new Task(
                    WhoId = leads[0].Id,
                    Subject = 'E-mail',
                    Status = 'Completed',
                    ActivityDate = Date.today().addDays(1)
                ),

                new Task(
                    WhoId = leads[1].Id,
                    Subject = 'E-mail',
                    Status = 'Completed',
                    ActivityDate = Date.today().addDays(1)
                ),

                new Task(
                    WhoId = leads[0].Id,
                    Subject = 'E-mail',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(1)
                ),

                new Task(
                    WhoId = leads[1].Id,
                    Subject = 'E-mail',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(1)
                )
            };



            TriggerHandler.bypass('LeadTriggerHandler');
            update oldLeadsMap.get(leads[1].Id);
            TriggerHandler.clearBypass('LeadTriggerHandler');

            
            insert new Event(
                WhoId = leads[1].Id,
                Type = 'Reunião',
                DurationInMinutes = 30,
                ActivityDateTime = Datetime.now()
            );

            leads[1].Status = 'Converted';

            LeadHelper.handleNewLeads(leads); // Agora passamos apenas a lista de Leads
        Test.stopTest();

        Assert.isFalse(leads[0].hasErrors());
        Assert.isFalse(leads[1].hasErrors());
        Assert.isTrue(leads[0].ConfiguracaoDeSLA__c != null);
    }

    @isTest
    private static void isMobilePhoneEqualTest() {
        List<Lead> leads = new List<Lead>{
            new Lead(
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '11',
                Celular__c = '1234-1234'
            ),
            new Lead(
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '11',
                Celular__c = '1234-1234'
            )
        };


        Assert.isTrue(LeadHelper.isMobilePhoneEqual(leads[0], leads[1]));
        leads[0].DDDCelular__c = '19';
        Assert.isFalse(LeadHelper.isMobilePhoneEqual(leads[0], leads[1]));
    }

    @isTest
    private static void isPhoneEqualTest() {
        List<Lead> leads = new List<Lead>{
            new Lead(
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '11',
                Phone = '1234-1234'
            ),
            new Lead(
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '11',
                Phone = '1234-1234'
            )
        };


        Assert.isTrue(LeadHelper.isPhoneEqual(leads[0], leads[1]));
        leads[0].DDDTelefone__c = '19';
        Assert.isFalse(LeadHelper.isPhoneEqual(leads[0], leads[1]));
    }

    @isTest
    private static void handleNewLeadsTest() {
        List<Lead> leads = new List<Lead> {
            new Lead(
                LastName = 'teste1845',
                Company = 'Company',
                Email = '4csdf@sdfds.com',
                DDDCelular__c = '11',
                DDICelular__c = 'Afeganistão (+93)',
                Celular__c = '12785-6789',
                DDDTelefone__c = '78',
                DDITelefone__c = 'Afeganistão (+93)',
                Phone = '12345-6778'
            ),
            new Lead(
                LastName = 'teste784545',
                Company = 'TulioCompany',
                Email = '474df@sdfds.com',
                OwnerId = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'Integracao'].get(0).Id,
                DDDCelular__c = '11',
                DDICelular__c = 'Afeganistão (+93)',
                Celular__c = '12785-1289',
                DDDTelefone__c = '78',
                DDITelefone__c = 'Afeganistão (+93)',
                Phone = '12345-6778'
            )
        };

        Test.startTest();
            LeadHelper.handleNewLeads(leads); // Passando apenas o parâmetro correto (leads)
        Test.stopTest();

        Assert.isTrue(leads.get(0).Status == 'Contacting');
        Assert.isTrue(leads.get(1).Status == 'New');
    }
}