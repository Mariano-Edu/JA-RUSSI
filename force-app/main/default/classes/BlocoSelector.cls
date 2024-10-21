public without sharing class BlocoSelector {
    public static List<Bloco__c> obterBlocosPorIdsEmpreendimentos(Set<Id> idsEmpreendimentos){
        return [SELECT Name, QuantidadeAndares__c, ChaveExterna__c, Empreendimento__c FROM Bloco__c WHERE Empreendimento__c IN :idsEmpreendimentos];
    }
}