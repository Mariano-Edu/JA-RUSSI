public with sharing class ComparativoController {
    @AuraEnabled(cacheable=true)
    public static List<Object> calcularComparacao(Id unidadeId, Id tabelaId, List<SeriePagamentos__c> proposta){
        List<Object> resultado = ComparativoService.calcularComparacao(unidadeId, tabelaId, proposta);
        System.debug(resultado);
        return resultado;
    }
}