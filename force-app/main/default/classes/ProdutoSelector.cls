public class ProdutoSelector {
    private static final Id VAGA_RECORD_TYPE_ID = Schema.SObjectType.Product2.getRecordTypeInfosByName()
    .get('Vaga')
    .getRecordTypeId();




    public static Product2 getProdutosById(Id id){
        return [
            SELECT
                Empreendimento__r.Name,
                Empreendimento__r.DiasDeVencimentoDaParcela__c,
                Name, Andar__c,
                MetragemTotal__c,
                NumeroDaUnidade__c,
                NumeroQuartos__c,
                QuantidadeVagas__c,
                Bloco__r.Name,
                PrecoLista__c,
                Family
            from Product2 where id = :id
        ];
    }

    public static Map<Id, Product2> CoeficienteProdutoPorId(List<Id> produtoIds) {
        Map<Id, Product2> produtoMap = new Map<Id, Product2>([
            SELECT
                Id,
                Coeficiente__c 
            FROM Product2 
            WHERE Id IN :produtoIds
        ]);
        return produtoMap;
    }

    // MetragemDaUnidadeM__c
    // ValorDaUnidade__c

    public static Map<Id, Product2> obterUnidadesRelacionadas(Set<Id> empreendimento){
        Map<Id, Product2> unidadesMap = new Map<Id, Product2>([
            SELECT
                Id,
                Name,
                ValorDaUnidade__c,
                Coeficiente__c,
                MetragemDaUnidadeM__c,
                Empreendimento__c
            FROM Product2 
            WHERE Empreendimento__c IN :empreendimento
        ]);
        return unidadesMap;
    }

    public static List<Product2> getProductsDisponivelByIdEmpreendimento(Id idEmpreendimento) {
        return [
            SELECT 
                Id,
                Name,
                ProductCode,
                QuantidadeVagas__c,
                ValorDaUnidade__c,
                Status__c,
                Andar__c,
                CorDisponivel__c,
                Bloco__r.name,
                RecordType.name,
                CorReservado__c,
                CorVendida__c,
                MetragemDaUnidadeM__c,
                NumeroDeSuites__c,
                NumeroQuartos__c,
                Empreendimento__r.Name,
                Empreendimento__r.DiasDeVencimentoDaParcela__c,
                NumeroDaUnidade__c
            FROM Product2
            WHERE 
                Status__c != '' AND
                Empreendimento__r.DisponivelNoEspelho__c = true AND
                Empreendimento__c = :idEmpreendimento
        ];
    }

    public static List<Product2> getProductsDisponivel() {
        return [
            SELECT 
                Id,
                Name,
                ProductCode,
                QuantidadeVagas__c,
                ValorDaUnidade__c,
                Status__c,
                Andar__c,
                CorDisponivel__c,
                Bloco__r.name,
                RecordType.name,
                CorReservado__c,
                CorVendida__c,
                MetragemDaUnidadeM__c,
                NumeroDeSuites__c,
                NumeroQuartos__c,
                Empreendimento__r.Name,
                Empreendimento__r.DiasDeVencimentoDaParcela__c,
                NumeroDaUnidade__c
            FROM Product2
            WHERE 
                Status__c != '' AND
                Empreendimento__r.DisponivelNoEspelho__c = true
        ];
    }


    public static List<Product2> getVagasGaragem(Id idEmpreendimento){
        System.debug('idEmpreendimento: ' + idEmpreendimento);

        return[

        SELECT 
        id,
        Name,
        Tipo__c,
        Status__c,
        VagasUnidade__c,
        AreaTotal__c,
        TipoVaga__c,
        Empreendimento__c, 
        Empreendimento__r.VagasUnidade__c,
        RecordType.Name 
        FROM Product2 
        WHERE
            Empreendimento__c = :idEmpreendimento
        AND RecordType.Name = 'Vaga'
        ];
    }

    public static List<Product2> getQtdVagas(Id idUnidade) {
        return 
        [
            SELECT 
            id,
            Name,
            QuantidadeVagas__c
            FROM Product2 
            WHERE 
            id = :idUnidade        
        ];
    }
}