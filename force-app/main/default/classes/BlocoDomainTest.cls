@isTest
private class BlocoDomainTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c>{
            new Empreendimento__c(
                Name = 'Empreendimento 1',
                CNPJ__c = '36020155000137'
            ),
            new Empreendimento__c(
                Name = 'Empreendimento 2',
                CNPJ__c = '36020155000137'
            )
        };

        insert empreendimentos;

        List<Bloco__c> blocos = new List<Bloco__c>{
            new Bloco__c(
                Name = 'Bloco 1',
                Empreendimento__c = empreendimentos.get(0).Id
            ),
            new Bloco__c(
                Name = 'Bloco 2',
                Empreendimento__c = empreendimentos.get(0).Id
            ),
            new Bloco__c(
                Name = 'Bloco 3',
                Empreendimento__c = empreendimentos.get(1).Id
            )
        };

        insert blocos;
    }

    @isTest
    private static void obterBlocosEmpreendimentoPorChaveExternaTest() {
        Id idEmpreendimento = [SELECT Id FROM Empreendimento__c WHERE Name = 'Empreendimento 1'].get(0).Id;

        Assert.isTrue(BlocoDomain.obterBlocosEmpreendimentoPorChaveExterna(idEmpreendimento).size() > 0);
    }
}