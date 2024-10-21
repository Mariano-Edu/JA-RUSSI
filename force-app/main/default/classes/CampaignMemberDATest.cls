@IsTest
private class CampaignMemberDATest {
    
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        Lead lead = new Lead(
                LastName = 'Teste', 
                Status = 'Novo',  
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',  
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789', 
                Email = 'teste@email.com', 
                MidiaAtual__c = 'Instagram', 
                LeadSource = 'Instagram'
                );
        Campaign campaign = new Campaign(Name = 'Teste', isActive = true);

        insert lead;
        insert campaign;

        insert new CampaignMember(LeadId = lead.Id, CampaignId = campaign.Id);
    }

    @IsTest
    private static void getByLeadCampaignTest() {

        List<Lead> leads = [SELECT Id FROM Lead];
        List<Campaign> campaigns = [SELECT Id FROM Campaign];

        Set<Id> setIdLead = new Map<Id,Lead>(leads).keySet();
        Set<Id> setIdCampaign = new Map<Id,Campaign>(campaigns).keySet();

        Test.startTest();

        List<CampaignMember> expectedCampaignMembers = CampaignMemberDA.getByLeadCampaign(
            new Set<String>{'Id'},
            setIdLead,
            setIdCampaign
        );

        Test.stopTest();

        Assert.areEqual(1, expectedCampaignMembers.size());
    }
}