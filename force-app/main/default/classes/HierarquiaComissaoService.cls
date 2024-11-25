public class HierarquiaComissaoService {
    public static Map<String,HierarquiaComissao__c> getHierarquiasByTabelaComissao(ID idTabela) {
        List<HierarquiaComissao__c> hierarquias = HierarquiaComissaoSelector.getHierarquiasByTabelaComissao(idTabela);
        Map<String,HierarquiaComissao__c> hierarquiasPorCargo = new Map<String,HierarquiaComissao__c>();

        for(HierarquiaComissao__c iHierarquia : hierarquias) {
            hierarquiasPorCargo.put(iHierarquia.Cargo__c, iHierarquia);
        }

        return hierarquiasPorCargo;
    }
}