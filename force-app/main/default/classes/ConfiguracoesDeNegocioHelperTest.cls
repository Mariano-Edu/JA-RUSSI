@isTest
public class ConfiguracoesDeNegocioHelperTest {
    

    @isTest
    static void validaDuplicado() {
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

        ConfiguracoesDeNegocio__c config = new ConfiguracoesDeNegocio__c(
            TempoDeSla__c = 5,
            Fase__c = 'Novo',
            tempoLimiteParaFarolAmarelo__c = 4,
            tempoLimiteParaFarolVermelho__c = 3,
            FaseParaRedirecionamentoDoLead__c = 'Lead Perdido',
            FilaParaRedirecionamentoDoLead__c = 'rock'
        );

        Test.startTest();
        try {
            insert config;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Já existe uma configuração de negócio para esta fase do Lead'));
        }
        Test.stopTest();
    }

    
    @isTest
    static void validaDuplicadoUpdate() {
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

        ConfiguracoesDeNegocio__c config = new ConfiguracoesDeNegocio__c(
            TempoDeSla__c = 5,
            Fase__c = 'Em Atendimento	',
            tempoLimiteParaFarolAmarelo__c = 4,
            tempoLimiteParaFarolVermelho__c = 3,
            FaseParaRedirecionamentoDoLead__c = 'Lead Perdido',
            FilaParaRedirecionamentoDoLead__c = 'rock'
        );

        insert config;

        Test.startTest();
        try {
            config.Fase__c = 'Novo';
            update config;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Já existe uma configuração de negócio para esta fase do Lead'));
        }
        Test.stopTest();
    }
}