@isTest
public class LeadDATest {
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        List<Lead> leads = new List<Lead> {
            new Lead(
                LastName = 'Teste3',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                Email = 'teste3@email.com',
                DDICelular__c = null,
                DDITelefone__c = null
            ),
            new Lead(
                LastName = 'Teste4',
                MidiaAtual__c = 'Instagram',
                LeadSource = 'Instagram',
                Email = 'teste4@email.com',
                DDICelular__c = null,
                DDITelefone__c = null
            )
        };

        insert leads;
    }

    @isTest
    public static void getLeadsByIdTest(){
        Lead lead = [SELECT Id, LastName FROM Lead].get(0);

        Set<Id> ids = new Set<Id>{lead.Id};

        Set<String> fields = new Set<String>{'Id', 'LastName'};
        
        Test.startTest();

        List<Lead> leadsById = LeadDA.getLeadsById(
            fields, 
            ids
        );

        Test.stopTest();

        Assert.isTrue(leadsById.size() == 1);
        Assert.isTrue(leadsById.get(0).LastName == lead.LastName);
    }

    @isTest
    public static void getLeadsByLastNameTest() {
        Set<String> fields = new Set<String>{'Id'};
        Set<String> lastNames = new Set<String>{'Teste3'};
        
        Assert.isTrue(
            LeadDA.getLeadsByLastName(
                fields,
                lastNames
            ).size() == 1);
    }

    @isTest
    public static void insertLeadsTest() {
        Test.startTest();
        LeadDA.insertLeads(
            new List<Lead>{
                new Lead(
                    LastName = 'Teste1',
                    LeadSource = 'Site',
                    MidiaAtual__c = 'Instagram',
                    CanalAtendimento__c = 'Chat',
                    DDITelefone__c = null,
                    DDICelular__c = null,
                    Email = 'teste1@email.com'
                ),
                new Lead(
                    LastName = 'Teste2',
                    LeadSource = 'Site',
                    MidiaAtual__c = 'Instagram',
                    CanalAtendimento__c = 'Chat',
                    DDITelefone__c = null,
                    DDICelular__c = null,
                    Email = 'teste2@email.com'
                )
            }
        );
        Test.stopTest();

        Assert.isTrue([SELECT COUNT() FROM Lead] == 4);
    }

    @isTest
    public static void updateLeadTest() {
        Lead toUpdate = [SELECT Id, LastName FROM Lead LIMIT 1];

        String newLastName = 'Changed';
        toUpdate.LastName = newLastName;

        LeadDA.updateLead(toUpdate);
        Assert.isTrue([SELECT COUNT() FROM Lead WHERE LastName = :newLastName ] == 1);
    }
    
}