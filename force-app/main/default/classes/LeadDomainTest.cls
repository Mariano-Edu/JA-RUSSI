@isTest
private class LeadDomainTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        List<Lead> leads = new List<Lead> {
            new Lead(
                LastName = 'Teste',
                Email = 'teste@email.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                CanalAtendimento__c = 'Web',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram'
            )
        };

        insert leads;
    }

    @isTest
    private static void obterLeadPorIdTest() {
        Id idLead = [SELECT Id FROM Lead LIMIT 1].get(0).Id;

        Assert.areEqual(new Lead(), LeadDomain.obterLeadPorId(null));
        Assert.areNotEqual(new Lead(), LeadDomain.obterLeadPorId(idLead));
    }

    @isTest
    private static void obterLeadsPorCanalAtendimentoTest() {
        Map<String, List<Lead>> leadsPorCanalAtendimento = LeadDomain.obterLeadsPorCanalAtendimento([SELECT Id, CanalAtendimento__c FROM Lead LIMIT 1]);
        
        Assert.areEqual(1, leadsPorCanalAtendimento.get('Web').size());
        Assert.areEqual(null, leadsPorCanalAtendimento.get('Outros'));
    }
}