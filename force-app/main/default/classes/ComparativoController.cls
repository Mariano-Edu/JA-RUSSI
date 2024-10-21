public with sharing class ComparativoController {
    @AuraEnabled(cacheable=true)
    public static List<Object> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta){
        List<Object> resultado = ComparativoService.calcularComparacao(tabelaId, proposta);
        System.debug(resultado);
        return resultado;
    }
}