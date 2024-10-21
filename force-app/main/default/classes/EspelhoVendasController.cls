public with sharing class EspelhoVendasController {

    @AuraEnabled(cacheable=true)
    public static List<Empreendimento__c> getEmpreendimentosDisponiveis() {
        return EspelhoVendasService.getEmpreendimentosDisponiveis();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> retornarUnidadesDisponiveis(Id idEmpreendimento) {
        return EspelhoVendasService.retornarUnidadesDisponiveis(idEmpreendimento);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> buscarNomesEmpreendimentos(){
       return EspelhoVendasService.buscarNomesEmpreendimentos();
    }

    @AuraEnabled(cacheable=true)
    public static List<Bloco__c> buscarBlocosPorEmpreendimento(Id idEmpreendimento){
       return EspelhoVendasService.buscarBlocosPorEmpreendimento(idEmpreendimento);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> buscarStatusUnidades(){
       return EspelhoVendasService.buscarStatusUnidades();
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> buscarTiposUnidades(){
       return EspelhoVendasService.buscarTiposUnidades();
    }

    @AuraEnabled(cacheable=true)
    public static List<ConfiguracaoSimulador__mdt> getConfiguracaoEspelho() {
        return EspelhoVendasService.getConfiguracaoEspelho();
    }
}