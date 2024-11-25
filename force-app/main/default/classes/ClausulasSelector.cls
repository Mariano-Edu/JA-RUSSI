public with sharing class ClausulasSelector {
    public static Map<String,Clausulas__c> getClausulasBySetCode(Set<String> setClasulasCode){
        Map<String,Clausulas__c> retMap = new Map<String,Clausulas__c>();
        for(Clausulas__c cl : [Select Id, Conteudo__c, Chave__c from Clausulas__c where Chave__c in: setClasulasCode]){
            retMap.put(cl.Chave__c, cl);
        }
        return retMap;
    }

    public static Map<String,Clausulas__c> getAllClausulasBySetCode(){
        Map<String,Clausulas__c> retMap = new Map<String,Clausulas__c>();
        for(Clausulas__c cl : [Select Id, Conteudo__c, Chave__c from Clausulas__c]){
            retMap.put(cl.Chave__c, cl);
        }
        return retMap;
    }
}