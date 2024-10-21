@isTest
private class EmpreendimentoTriggerHandlerTest {

    @testSetup
    static void setupData() {
        // Você pode adicionar mais dados de preparação, se necessário
    }

    @isTest
    static void testBeforeInsert() {
        Test.startTest();
        
        // Caso com CEP e CNPJ válido
        Empreendimento__c emp = new Empreendimento__c(
            Name = 'Test Empreendimento Insert', 
            CNPJ__c = '36120131000150', // CNPJ válido sem caracteres especiais
            CEP__c = '01001000'
        );
        insert emp;
        
        // Caso sem CEP com CNPJ válido
        Empreendimento__c empWithoutCEP = new Empreendimento__c(
            Name = 'Test Empreendimento No CEP', 
            CNPJ__c = '81956335000180' // Outro CNPJ válido sem caracteres especiais
        );
        insert empWithoutCEP;
        
        Test.stopTest();
        
        // Verificar se o CEP foi inserido corretamente no primeiro caso
        Empreendimento__c insertedEmp = [SELECT CEP__c FROM Empreendimento__c WHERE Id = :emp.Id LIMIT 1];
        System.assertEquals('01001000', insertedEmp.CEP__c, 'O CEP deve ser inserido corretamente.');
        
        // Verificar que o segundo Empreendimento foi inserido sem CEP
        Empreendimento__c insertedEmpWithoutCEP = [SELECT CEP__c FROM Empreendimento__c WHERE Id = :empWithoutCEP.Id LIMIT 1];
        System.assertEquals(null, insertedEmpWithoutCEP.CEP__c, 'O Empreendimento sem CEP deve ser inserido corretamente.');
    }

    @isTest
    static void testBeforeUpdate() {
        // Inserir um registro inicial com CNPJ válido
        Empreendimento__c emp = new Empreendimento__c(
            Name = 'Test Empreendimento Update', 
            CNPJ__c = '05971251000137', // CNPJ válido sem caracteres especiais
            CEP__c = '68904620'
        );
        insert emp;
        
        // Atualizar o CEP
        emp.CEP__c = '01001000';
        
        Test.startTest();
        update emp;
        Test.stopTest();

        // Verificar se o CEP foi atualizado corretamente
        Empreendimento__c updatedEmp = [SELECT CEP__c FROM Empreendimento__c WHERE Id = :emp.Id LIMIT 1];
        System.assertEquals('01001000', updatedEmp.CEP__c, 'O CEP deve ser atualizado corretamente.');
    }

    @isTest
    static void testBeforeUpdateWithoutCEPChange() {
        // Testar atualização sem alteração no CEP e com CNPJ válido
        Empreendimento__c emp = new Empreendimento__c(
            Name = 'Test Empreendimento No CEP Change', 
            CNPJ__c = '35627368000169', // CNPJ válido sem caracteres especiais
            CEP__c = '68904620'
        );
        insert emp;
        
        // Atualizar o nome, mas não o CEP
        emp.Name = 'Updated Name';
        
        Test.startTest();
        update emp;
        Test.stopTest();
        
        // Verificar que o CEP não foi alterado
        Empreendimento__c updatedEmp = [SELECT CEP__c, Name FROM Empreendimento__c WHERE Id = :emp.Id LIMIT 1];
        System.assertEquals('68904620', updatedEmp.CEP__c, 'O CEP não deve ser alterado.');
        System.assertEquals('Updated Name', updatedEmp.Name, 'O nome deve ser atualizado.');
    }

    @isTest
    static void testBatchContext() {
        // Simulando um contexto de batch com CNPJ válido
        Test.startTest();
        Empreendimento__c emp = new Empreendimento__c(
            Name = 'Test Empreendimento Batch', 
            CNPJ__c = '41649881000153', // CNPJ válido sem caracteres especiais
            CEP__c = '01001000'
        );
        insert emp;
        Test.stopTest();
        
        // Verificar se o Empreendimento foi inserido
        Empreendimento__c insertedEmp = [SELECT CEP__c FROM Empreendimento__c WHERE Id = :emp.Id LIMIT 1];
        System.assertNotEquals(null, insertedEmp.CEP__c, 'O CEP deve ser inserido corretamente em um contexto de batch.');
    }
}