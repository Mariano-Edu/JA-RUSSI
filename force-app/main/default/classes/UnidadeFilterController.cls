public class UnidadeFilterController {
    @InvocableMethod
    public static List<Product2> getUnidadesFiltradas(List<Id> unidadeTabelaIds) {
        List<UnidadeTabelaVendas__c> unidadesTabela = [
            SELECT 
                TabelaVenda__r.Empreendimento__c
            FROM UnidadeTabelaVendas__c WHERE Id IN :unidadeTabelaIds
        ];

        return [
            SELECT 
                Id,
                Name
            FROM Product2
            WHERE Empreendimento__c IN :ObjectHelper.getLookUpId(unidadesTabela, 'TabelaVendas__r.Empreendimento__c')
        ];
    }
}