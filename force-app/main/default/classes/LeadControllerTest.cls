@isTest
private class LeadControllerTest {

    @isTest
    static void testGetMotivosPerda() {
        Test.startTest();
        Map<String, String> resultados = LeadController.getMotivosPerda();
        Test.stopTest();

        System.assertNotEquals(null, resultados, 'O retorno de getMotivosPerda não deve ser nulo.');
    }

    @isTest
    static void testAlterarStatusParaPerdido() {
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Status = 'Prospect',
            Email = 'test@email.com',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Instagram',
            DDICelular__c = null,
            DDITelefone__c = null
        );
        insert lead;

        String motivo = 'Acima do valor procurado';

        Test.startTest();
        LeadController.alterarStatusParaPerdido(lead.Id, motivo);
        Test.stopTest();

        Lead leadAtualizado = [SELECT Status, MotivoLeadPerdido__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        
        System.assertEquals('Lost', leadAtualizado.Status, 'O status do Lead deve ser "Lost".');
        System.assertEquals(motivo, leadAtualizado.MotivoLeadPerdido__c, 'O motivo de perda deve ser igual ao fornecido.');
    }
}