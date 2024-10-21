public with sharing class LeadVencidoBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, 
                   ConfiguracaoDeSLA__c,
                   ConfiguracaoDeSLA__r.Fase__c, 
                   ConfiguracaoDeSLA__r.motivoDaPerda__c, 
                   ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c, 
                   ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c,
                   OwnerId,
                   Vencido__c,
                   Status
            FROM Lead 
            WHERE Vencido__c = true
            AND Status <> 'Lost'
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        LeadVencidoHelper.getInstance().atualizaLeadVencido(scope);
    }
    
    public void finish(Database.BatchableContext BC) {

    }
}