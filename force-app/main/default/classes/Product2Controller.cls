public with sharing class Product2Controller {
    
    @AuraEnabled(cacheable = true)
    public static List<Product2> getVagasPorEmpreendimento(Id idEmpreendimento) {
        return Product2Service.getVagasPorEmpreendimento(idEmpreendimento);
    }
}