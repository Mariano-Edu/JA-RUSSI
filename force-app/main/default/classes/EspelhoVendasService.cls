public with sharing class EspelhoVendasService {
    public static List<Empreendimento__c> getEmpreendimentosDisponiveis() {
        return [
            SELECT Id, Name
            FROM Empreendimento__c
            WHERE DisponivelNoEspelho__c = true
        ];  
    }
  
    public static List<Product2> retornarUnidadesDisponiveis(Id idEmpreendimento) {
        return ProdutoSelector.getProductsDisponivelByIdEmpreendimento(idEmpreendimento);
    }

    public static List<Product2> getTodasUnidadesDisponiveis() {
        return ProdutoSelector.getProductsDisponivel();
    }
    
    public static List<String> buscarNomesEmpreendimentos() {
        List<Product2> products = [SELECT Empreendimento__r.Name FROM Product2 WHERE Empreendimento__r.Name != NULL];
        Set<String> empreendimentoNames = new Set<String>();

        for (Product2 product : products) {
            if (product.Empreendimento__r != null && product.Empreendimento__r.Name != null) {
                empreendimentoNames.add(product.Empreendimento__r.Name);
            }
        }

        return new List<String>(empreendimentoNames);
    }
    
    public static List<Bloco__c> buscarBlocosPorEmpreendimento(Id idEmpreendimento) {
        return [SELECT Id, Name FROM Bloco__c WHERE Empreendimento__c = :idEmpreendimento];
    }
    
    public static List<ConfiguracaoSimulador__mdt> getConfiguracaoEspelho() {
        List<ConfiguracaoSimulador__mdt> configuracoes = [SELECT Id, Status__c, Cor__c FROM ConfiguracaoSimulador__mdt];
        return configuracoes != null ? configuracoes : new List<ConfiguracaoSimulador__mdt>();
    }
    
    public static List<String> buscarStatusUnidades() {
        List<Product2> products = [SELECT Status__c FROM Product2 WHERE Status__c != NULL];
        Set<String> statusSet = new Set<String>();
        for (Product2 product : products) {
            if (product.Status__c != null) {
                statusSet.add(product.Status__c);
            }
        }
        return new List<String>(statusSet);
    }

    public static List<RecordType> buscarTiposUnidades() {
        return [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Product2'];
    }
}