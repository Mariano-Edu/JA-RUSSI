public class comissaoController {
    @AuraEnabled
    public static List<Object> analisarProposta(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz){
        List<Object> resultado = ExtratoTabelaService.analisarProposta(tabelaId, proposta, valoresMatriz);
        return resultado;
    }
}