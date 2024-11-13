@isTest
private class Product2ControllerTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento',
            CNPJ__c = '10155540000106',
            ValorMetroQuadrado__c  = 300000.0
        );

        insert empreendimento;

        Id vagaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vaga' AND SObjectType = 'Product2' LIMIT 1].Id;
        Id unidadeRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Unidade' AND SObjectType = 'Product2' LIMIT 1].Id;

        insert new List<Product2>{
            new Product2(
                Name = 'Unidade 1',
                Empreendimento__c = empreendimento.Id,
                RecordTypeId = unidadeRecordType,
                MetragemDaUnidadeM__c = 30
            ),
            new Product2(
                Name = 'Vaga 1',
                Empreendimento__c = empreendimento.Id,
                RecordTypeId = vagaRecordType,
                ValorVaga__c = 200000.0
            ),
            new Product2(
                Name = 'Vaga 2',
                Empreendimento__c = empreendimento.Id,
                RecordTypeId = vagaRecordType,
                ValorVaga__c = 300000.0
            )
        };
    }

    @isTest
    static void getVagasGaragemTest() {
        Id vagaRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vaga' AND SObjectType = 'Product2' LIMIT 1].Id;
        Id empreendimentoId = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;
        
        List<Product2> vagas = [SELECT Id FROM Product2 WHERE RecordTypeId = :vagaRecordType];
        List<Product2> vagasToTest = Product2Controller.getVagasGaragem(empreendimentoId);
        
        Assert.areEqual(vagas.size(), vagasToTest.size());
    }
}