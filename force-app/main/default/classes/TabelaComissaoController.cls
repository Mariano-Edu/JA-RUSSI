public class TabelaComissaoController {
    
    @AuraEnabled(cacheable = true)
    public static List<TabelaComissao__c> getTabelasComissao(Id idTabela, Id idEmpreendimento, String empresaVenda) {
        if(idTabela == null || idEmpreendimento == null || String.isBlank(empresaVenda)) {
            AuraHandledException e = new AuraHandledException('');
            e.setMessage('Parâmetros inválidos para consulta de tabelas de comissão.');
            throw e;
        }

        return TabelaComissaoService.getTabelasComissao(idTabela, idEmpreendimento, empresaVenda);
    }
}