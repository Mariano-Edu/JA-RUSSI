public with sharing class MinutaSelector {
    
    public static Map<Id,Minuta__c> getMinutasFromId(Id minutaId){
        return new Map<Id,Minuta__c>([Select Id, Corpo__c from Minuta__c where Id =: minutaId]);
    }

    public static Minuta__c getMinutaFromEmpreendimentoId(Id empreendimentoId){
        return [Select Id, Corpo__c from Minuta__c 
                where Id IN (Select Minuta__c from MinutaEmpreendimento__c where Empreendimento__c =: empreendimentoId and Ativo__c =: true) Limit 1];
    } 
}