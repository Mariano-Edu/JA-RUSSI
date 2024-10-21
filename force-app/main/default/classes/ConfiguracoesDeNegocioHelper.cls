public with sharing class ConfiguracoesDeNegocioHelper {

    private static ConfiguracoesDeNegocioHelper instance = new ConfiguracoesDeNegocioHelper();
    public static ConfiguracoesDeNegocioHelper getInstance(){
        return instance;
    }
    
    public void validaDuplicado(List<ConfiguracoesDeNegocio__c> configuracoes) {
        Set<String> fases = new Set<String>();
        List<ConfiguracoesDeNegocio__c> configuracoesByFase = new List<ConfiguracoesDeNegocio__c>();
        for(ConfiguracoesDeNegocio__c configuracao : configuracoes) {
            if(!String.isEmpty(configuracao.Fase__c)) fases.add(configuracao.Fase__c);
        }

        if(fases.isEmpty()) return;
        configuracoesByFase = ConfiguracoesDeNegocioRepository.getInstance().getByFases(fases);
        if(configuracoesByFase.isEmpty()) return;

        for(ConfiguracoesDeNegocio__c configuracao : configuracoes) {
           
            for(ConfiguracoesDeNegocio__c configByFase : configuracoesByFase) {
                if(configuracao.Id != configByFase.Id && configuracao.Fase__c == configByFase.Fase__c) {
                    configuracao.addError('Já existe uma configuração de negócio para esta fase do Lead');
                }
            }

        }

    }
}