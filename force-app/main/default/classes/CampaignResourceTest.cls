@isTest
private class CampaignResourceTest {

    @TestSetup
    static void makeData(){
        Campaign campanhaTeste01 = new Campaign (
            name = 'Instagram',
            isActive = true
        );

        insert campanhaTeste01;

        List<Lead> leads = new List<Lead> {
            new Lead (
                LastName = 'Souza',
                campanha__c = campanhaTeste01.Id,
                Email = 'souza@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6779',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18815-6789',
                MidiaAtual__c = 'Instagram', // Usando a opção do campo MidiaAtual__c
                LeadSource = 'Instagram'
            ),

            new Lead (
                LastName = 'Souza2',
                campanha__c = campanhaTeste01.Id,
                Email = 'souza2@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6709',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18945-6789',
                MidiaAtual__c = 'Facebook Ads', // Outra opção do campo MidiaAtual__c
                LeadSource = 'Facebook'
            )
        };

        insert leads; 
        
        // Registrando o primeiro Lead como membro da campanha
        insert new CampaignMember(LeadId = leads.get(0).Id, CampaignId = campanhaTeste01.Id);
    }

    @isTest
    static void testRegisterCampaignWithValidLeads(){
        List<Lead> leads = [SELECT Id, Campanha__c FROM Lead];
        
        Test.startTest();
            CampaignResource.registerCampaign(leads);
        Test.stopTest();
        
        // Verificar se agora temos 2 CampaignMembers (um já existente + um novo)
        List<CampaignMember> membrosCampanha = [SELECT Id, Status, CampaignId, LeadId FROM CampaignMember];
        
        System.debug('Total CampaignMembers after registering: ' + membrosCampanha.size());
        for (CampaignMember cm : membrosCampanha) {
            System.debug('CampaignMember: ' + cm.LeadId + ', Status: ' + cm.Status);
        }

        // Como já temos 1 CampaignMember e registramos mais um, agora devem haver 2
        Assert.areEqual(2, membrosCampanha.size(), 'Deveria haver 2 CampaignMembers após o registro.');

        // Verifica se o novo membro foi registrado com o status correto
        CampaignMember novoMembro = [SELECT Id, Status, LeadId FROM CampaignMember WHERE LeadId = :leads.get(1).Id LIMIT 1];
        Assert.areEqual('Sent', novoMembro.Status, 'O Status do novo CampaignMember deveria ser "Sent".');
    }

    @isTest
    static void testRegisterCampaignWithExistingMember(){
        List<Lead> leadsAlreadyMember = [SELECT Id, Campanha__c FROM Lead WHERE Campanha__c != null LIMIT 1];
        Integer beforeNumber = [SELECT COUNT() FROM CampaignMember];

        Test.startTest();
            CampaignResource.registerCampaign(leadsAlreadyMember);
        Test.stopTest();
        
        // O número de CampaignMembers não deve aumentar, pois o lead já é membro
        List<CampaignMember> membrosCampanhaAfter = [SELECT Id, Status FROM CampaignMember];
        
        System.debug('Total CampaignMembers after trying to register existing member: ' + membrosCampanhaAfter.size());
        Assert.areEqual(beforeNumber, membrosCampanhaAfter.size(), 'O número de CampaignMembers não deve aumentar.');
    }

    @isTest
    static void testRegisterCampaignWithLeadWithoutCampaign(){
        Lead leadSemCampanha = new Lead(
            LastName = 'SemCampanha',
            Email = 'semcampanha@email.com',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18845-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-6789',
            MidiaAtual__c = 'Youtube', // Usando uma opção válida
            LeadSource = 'Youtube'
        );

        insert leadSemCampanha;

        List<Lead> leadsSemCampanha = [SELECT Id, Campanha__c FROM Lead WHERE Id = :leadSemCampanha.Id];

        Test.startTest();
            CampaignResource.registerCampaign(leadsSemCampanha);
        Test.stopTest();

        // Nenhum novo CampaignMember deve ser criado
        List<CampaignMember> membrosCampanhaSem = [SELECT Id FROM CampaignMember WHERE LeadId = :leadSemCampanha.Id];
        Assert.areEqual(0, membrosCampanhaSem.size(), 'Nenhum CampaignMember deveria ser criado.');
    }

    @isTest
    static void testRegisterCampaignWithEmptyLeadList(){
        List<Lead> leadsVazia = new List<Lead>();
        Integer beforeNumber = [SELECT COUNT() FROM CampaignMember];

        Test.startTest();
            CampaignResource.registerCampaign(leadsVazia);
        Test.stopTest();

        // Nada deve acontecer, sem erros
        Assert.areEqual(beforeNumber, [SELECT COUNT() FROM CampaignMember], 'O número de CampaignMembers deve permanecer o mesmo.');
    }
}