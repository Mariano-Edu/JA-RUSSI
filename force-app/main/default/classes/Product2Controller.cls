public with sharing class Product2Controller {
    
 /*    @AuraEnabled(cacheable = true)
    public static List<Product2> getVagasPorEmpreendimento(Id idEmpreendimento) {
        return Product2Service.getVagasPorEmpreendimento(idEmpreendimento);
    } */

    @AuraEnabled(cacheable = true)
    public static List<Product2> getVagasGaragem(Id idEmpreendimento) {
        System.debug(idEmpreendimento);
        return Product2Service.getVagasGaragem(idEmpreendimento);
    }
}