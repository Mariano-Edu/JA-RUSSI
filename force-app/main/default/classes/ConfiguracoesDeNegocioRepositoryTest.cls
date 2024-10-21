@isTest
public class ConfiguracoesDeNegocioRepositoryTest {
    
    @TestSetup
    static void makeData(){
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 5,
                Fase__c = 'Novo',
                tempoLimiteParaFarolAmarelo__c = 4,
                tempoLimiteParaFarolVermelho__c = 3,
                FaseParaRedirecionamentoDoLead__c = 'Lead Perdido',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;
    }

    @isTest
    static void getByFases() {
        Set<String> fases = new Set<String>{'Novo'};
        List<ConfiguracoesDeNegocio__c> configuracoes = new List<ConfiguracoesDeNegocio__c>();

        Test.startTest();
        configuracoes = ConfiguracoesDeNegocioRepository.getInstance().getByFases(fases);
        Test.stopTest();

        System.assert(!configuracoes.isEmpty());
    }
}