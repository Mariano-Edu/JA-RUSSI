@isTest
private class LeadSelectorTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        List<Lead> leads = new List<Lead>{
            new Lead(
                LastName = 'Teste1',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                Email = 'teste1@teste.com'
            ),

            new Lead(
                LastName = 'Teste2',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '28845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '13845-6789',
                Email = 'teste2@teste.com'
            )
        };

        insert leads;
    }

    @isTest
    static void obterLeadsPorIdsTest() {
        List<Lead> leads = [SELECT Name, FirstName, LastName, CelularFormatado__c, TelefoneFormatado__c, Email, Status, Owner.Name FROM Lead];
        Set<Id> idsLeads = new Map<Id,Lead>(leads).keySet();

        Assert.areEqual(idsLeads, new Map<Id,Lead>(LeadSelector.obterLeadsPorIds(idsLeads)).keySet());
    }

    @isTest
    static void obterLeadsPorInformacoesConciergeTest() {
        List<Lead> leads = [SELECT Name, FirstName, LastName, CelularFormatado__c, TelefoneFormatado__c, Email, Status, Owner.Name FROM Lead WHERE LastName LIKE '%Teste1%'];
        
        Assert.areEqual(leads, LeadSelector.obterLeadsPorInformacoesConcierge('LastName LIKE \'%Teste1%\''));
    }
}