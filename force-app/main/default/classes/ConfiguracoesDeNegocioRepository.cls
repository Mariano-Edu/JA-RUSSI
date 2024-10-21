public virtual class ConfiguracoesDeNegocioRepository {

    private static ConfiguracoesDeNegocioRepository instance = new ConfiguracoesDeNegocioRepository();
    public static ConfiguracoesDeNegocioRepository getInstance(){
        return instance;
    }

    virtual
    public List<ConfiguracoesDeNegocio__c> getByFases(Set<String> fases) {
        return [SELECT Id, Fase__c FROM ConfiguracoesDeNegocio__c WHERE Fase__c IN : fases];
    }
}