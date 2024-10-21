@isTest
private class BlocoSelectorTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c>{
            new Empreendimento__c(
                Name = 'Empreendimento 1',
                CNPJ__c = '42318254000100'
            ),
            new Empreendimento__c(
                Name = 'Empreendimento 2',
                CNPJ__c = '21268544000109'
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
    static void obterBlocosPorIdsEmpreendimentosTest() {
        Set<Id> idsEmpreendimentos = new Set<Id>();

        for (Empreendimento__c e : [SELECT Id FROM Empreendimento__c]) {
            idsEmpreendimentos.add(e.Id);
        }

        List<Bloco__c> blocos = [SELECT Name, QuantidadeAndares__c, ChaveExterna__c, Empreendimento__c FROM Bloco__c WHERE Empreendimento__c IN :idsEmpreendimentos];

        Assert.areEqual(blocos, BlocoSelector.obterBlocosPorIdsEmpreendimentos(idsEmpreendimentos));
        Assert.isTrue(BlocoSelector.obterBlocosPorIdsEmpreendimentos(idsEmpreendimentos).size() > 0);
    }

}