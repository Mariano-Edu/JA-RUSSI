@isTest
private class ObjectHelperTest {
    
    @TestSetup
    static void makeData(){
        doMakeData();
    }

    private static void doMakeData(){
        
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento',
            CNPJ__c = '10155540000106'
        );

        insert empreendimento;

        Lead lead = new Lead(
            LastName = 'Zika',
            Company = 'Chave',
            Email = 'em@em.com',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '16',
            Phone = '18845-6789',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '16',
            Celular__c = '18845-6789',
            EmpreendimentoInteresse__c = empreendimento.Id,
            Status = 'New', 
            CNPJ__c = '57357637000157', 
            MidiaAtual__c = 'Instagram', 
            LeadSource = 'Instagram' 
        );
        
        insert lead;
    }

    @isTest
    private static void getLookUpId(){
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].get(0);
        List<Lead> leads = [SELECT Id, EmpreendimentoInteresse__c FROM Lead];

        Set<Id> empreendimentosId = new Set<Id>();

        Test.startTest();
        empreendimentosId = ObjectHelper.getLookUpId(leads, 'EmpreendimentoInteresse__c');
        Test.stopTest();

        Assert.isTrue(empreendimentosId.contains(empreendimento.Id));
    }

    @IsTest
    private static void isEqualFieldTest() {
        // Criando dois Leads com sobrenomes iguais e primeiros nomes diferentes
        Lead lead1 = new Lead (
                LastName = 'Jorge',
                FirstName = 'A',
                Company = 'Test Company',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18845-6789',
                Status = 'New',
                CNPJ__c = '57357637000157'
                );
        Lead lead2 = new Lead (
                LastName = 'Jorge',
                FirstName = 'B',
                Company = 'Test Company',
                Status = 'New',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18445-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c = '18445-6789',
                CNPJ__c = '57357637000157'
                );

        // Verificando se os campos LastName são iguais e FirstName são diferentes
        Assert.isTrue(ObjectHelper.isEqualField(lead1, lead2, 'LastName'));
        Assert.isFalse(ObjectHelper.isEqualField(lead1, lead2, 'FirstName'));
    }

    @IsTest
    private static void getFieldValuesFromListTest() {
        List<Lead> leads = new List<Lead> {
            new Lead (LastName = 'Jorge', FirstName = 'A', Company = 'Test Company', Status = 'New', CNPJ__c = '57357637000157'),
            new Lead (LastName = 'Jorge', FirstName = 'AB', Company = 'Test Company', Status = 'New', CNPJ__c = '57357637000157')
        };

        Test.startTest();
        Set<String> firstNameSet = ObjectHelper.getFieldValuesFromList(leads, 'FirstName');
        Test.stopTest();

        Assert.isTrue(firstNameSet.contains(leads.get(0).FirstName));
        Assert.isTrue(firstNameSet.contains(leads.get(1).FirstName));
    }

    @IsTest
    private static void updateFieldsTest() {
        // Criando dois Leads
        Lead lead1 = new Lead (LastName = 'Jorge', FirstName = 'A', Company = 'Test Company', Status = 'New', CNPJ__c = '57357637000157');
        Lead lead2 = new Lead (LastName = 'Jorge', FirstName = 'B', Company = 'Test Company', Status = 'New', CNPJ__c = '57357637000157');

        // Atualizando o campo FirstName do lead1 com o valor de lead2
        Test.startTest();
        ObjectHelper.updateFields(lead1, lead2, new Set<String>{'FirstName'});
        Test.stopTest();

        // Verificando se o campo FirstName foi atualizado corretamente
        Assert.isTrue(lead1.FirstName == lead2.FirstName);
    }

    @IsTest
    private static void getFieldSetTest() {
        SObjectType leadType = Schema.getGlobalDescribe().get('Lead');
        
        // Obtendo o mapa de campos do objeto Lead
        Map<String,Schema.SObjectField> mfields = leadType.getDescribe().fields.getMap();

        List<String> expectedFields = new List<String>();

        // Adicionando os campos esperados à lista
        for (String field : mfields.keySet()) {
            expectedFields.add(mfields.get(field).toString());
        }

        // Testando o método getFieldSet
        Test.startTest();
        List<String> actualFields = new List<String>(ObjectHelper.getFieldSet('Lead'));
        Test.stopTest();

        // Verificando se os campos retornados estão corretos
        Assert.areEqual(expectedFields.size(), actualFields.size());

        for (Integer i = 0; i < expectedFields.size(); i++) {
            Assert.isTrue(expectedFields[i] == actualFields[i]);
        }
    }

    @isTest
    private static void getPickListLabelTest() {
        // Testando a obtenção do rótulo de um valor de lista de seleção
        Test.startTest();
        String correctValueLabel = ObjectHelper.getPickListLabel('Lead', 'Status', 'New');
        String incorrectValueLabel = ObjectHelper.getPickListLabel('Lead', 'Status', 'Teste');
        Test.stopTest();

        // Verificando se o valor correto foi obtido e o valor incorreto retornou nulo
        Assert.isTrue(correctValueLabel == 'Prospect');
        Assert.isNull(incorrectValueLabel);
    }

    @isTest
    private static void containsAnyTest() {
        Set<String> set1 = new Set<String>{'a', 'b', 'c'};
        Set<String> set2 = new Set<String>{'c', 'd', 'e'};
        Set<String> set3 = new Set<String>{'f', 'g', 'h'};

        Test.startTest();
        Boolean cenario1 = ObjectHelper.containsAny(set1, set2);
        Boolean cenario2 = ObjectHelper.containsAny(set2, set3);
        Test.stopTest();

        Assert.isTrue(cenario1);
        Assert.isFalse(cenario2);
    }

    @isTest
    private static void getIdValuesFromListTest() {
        List<Lead> leads = [SELECT Id FROM Lead];

        Test.startTest();
        Set<Id> ids = ObjectHelper.getIdValuesFromList(leads);
        Test.stopTest();

        for (Lead iLead : leads) {
            Assert.isTrue(ids.contains(iLead.Id));
        }
    }
}