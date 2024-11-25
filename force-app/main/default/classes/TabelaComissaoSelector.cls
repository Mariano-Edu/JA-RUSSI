public class TabelaComissaoSelector {
    public static List<TabelaComissao__c> getTabelasComissao(Id idTabela, Id idEmpreendimento, String empresaVenda) {
        return [
            SELECT 
                Id,
                Name,
                PercentualComissao__c,
                EmpresaVenda__c,
                ValorPremio__c
            FROM TabelaComissao__c 
            WHERE 
                (TabelaVenda__c = :idTabela OR Empreendimento__c = :idEmpreendimento) AND
                EmpresaVenda__c = :empresaVenda AND
                Ativa__c = true
        ];
    }
}