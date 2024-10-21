@isTest
public class LeadReiterationHelperTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }
    
    private static void doCreateData() {
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJ__c = '23365363000126'
        );

        insert empreendimento;

        insert new Lead(
            LastName = 'Original',
            Email = 'teste@email.com',
            MidiaAtual__c = 'Instagram',
            LeadSource = 'Corretores',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '11',
            Celular__c = '99999-9999',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '11',
            Phone = '0000-0000',
            EmpreendimentoInteresse__c = empreendimento.Id,
            CPF__c = '54790801489',
            CNPJ__c = '91397144000189'
        );

        Lead lead = [SELECT MidiaOriginal__c, PrimeiraOrigem__c, PrimeiroEmpreendimento__c FROM Lead LIMIT 1];
        Assert.areEqual('Instagram', lead.MidiaOriginal__c, 'Midia Original deve ser Instagram na criação do Lead');
        Assert.areEqual('Corretores', lead.PrimeiraOrigem__c, 'Primeira Origem deve ser Corretores na criação do Lead');
        Assert.isNotNull(lead.PrimeiroEmpreendimento__c, 'Primeiro Empreendimento deve ser preenchido na criação do Lead');
    }

    @isTest
    private static void reiterationEmailTest() {
        Test.startTest();

        Lead original = [SELECT Id, LastName, Celular__c, Phone, Email, MidiaAtual__c, MidiaOriginal__c, PrimeiraOrigem__c, PrimeiroEmpreendimento__c, EmpreendimentoInteresse__c, LeadSource FROM Lead LIMIT 1];

        Empreendimento__c novoEmpreendimento = new Empreendimento__c(
            Name = 'Empreendimento 2',
            CNPJ__c = '81444534000109'
        );

        insert novoEmpreendimento;

        insert new Lead(
            LastName = 'Duplicado',
            Email = original.Email,
            MidiaAtual__c = 'Facebook Ads',
            LeadSource = 'Instagram',
            DDICelular__c = 'Brasil (+55)',
            DDDCelular__c = '11',
            Celular__c = '99999-9998',
            DDITelefone__c = 'Brasil (+55)',
            DDDTelefone__c = '11',
            Phone = '0000-0001',
            EmpreendimentoInteresse__c = novoEmpreendimento.Id
        );

        List<Lead> reiterados = [SELECT Id, LastName, Celular__c, Phone, Email, MidiaAtual__c, MidiaOriginal__c, PrimeiraOrigem__c, PrimeiroEmpreendimento__c, EmpreendimentoInteresse__c, LeadSource FROM Lead WHERE Email = :original.Email];
        
        Assert.areEqual(reiterados.size(), 1, 'Não deve haver Leads duplicados');
        
        Lead reiterado = reiterados[0];

        Assert.areNotEqual(original.LastName, reiterado.LastName, 'LastName deve ter seu valor atualizado');
        Assert.areNotEqual(original.Celular__c, reiterado.Celular__c, 'Celular__c deve ter seu valor atualizado');
        Assert.areNotEqual(original.Phone, reiterado.Phone, 'Phone deve ter seu valor atualizado');
        Assert.areNotEqual(original.MidiaAtual__c, reiterado.MidiaAtual__c, 'MidiaAtual__c deve ter seu valor atualizado');
        Assert.areNotEqual(original.LeadSource, reiterado.LeadSource, 'LeadSource deve ter seu valor atualizado');
        Assert.areNotEqual(original.EmpreendimentoInteresse__c, reiterado.EmpreendimentoInteresse__c, 'EmpreendimentoInteresse__c deve ter seu valor atualizado');

        Assert.areEqual(original.Email, reiterado.Email, 'Email não deve ter seu valor alterado após reiteração');
        Assert.areEqual(original.MidiaOriginal__c, reiterado.MidiaOriginal__c, 'MidiaOriginal__c não deve ter seu valor alterado após reiteração');
        Assert.areEqual(original.PrimeiraOrigem__c, reiterado.PrimeiraOrigem__c, 'PrimeiraOrigem__c não deve ter seu valor alterado após reiteração');
        Assert.areEqual(original.PrimeiroEmpreendimento__c, reiterado.PrimeiroEmpreendimento__c, 'PrimeiroEmpreendimento__c não deve ter seu valor alterado após reiteração');

        List<Task> tasksReiteracao = [SELECT Id, Subject FROM Task WHERE WhoId = :original.Id AND Subject = 'Reiteração'];
        Assert.areEqual(1, reiterados.size(), 'Não deve haver Leads duplicados');

        Test.stopTest();
    }

    @isTest
    private static void reiterationCelularTest() {
        Test.startTest();
        Lead original = [SELECT Id, DDICelular__c, DDDCelular__c, Celular__c, LastName FROM Lead LIMIT 1];

        insert new Lead(
            LastName = 'Duplicado',
            DDICelular__c = original.DDICelular__c,
            DDDCelular__c = original.DDDCelular__c,
            Celular__c = original.Celular__c,
            MidiaAtual__c = 'Facebook Ads',
            LeadSource = 'Instagram'
        );

        List<Lead> reiterados = [SELECT Id, LastName FROM Lead WHERE DDICelular__c = :original.DDICelular__c AND DDDCelular__c = :original.DDDCelular__c AND Celular__c = :original.Celular__c];
        Assert.areEqual(1, reiterados.size(), 'Não deve haver Leads duplicados');
        Assert.areNotEqual(original.LastName, reiterados[0].LastName, 'LastName deve ter seu valor atualizado');
        Test.stopTest();
    }

    @isTest
    private static void reiterationTelefoneTest() {
        Test.startTest();
        Lead original = [SELECT Id, DDITelefone__c, DDDTelefone__c, Phone, LastName FROM Lead LIMIT 1];

        insert new Lead(
            LastName = 'Duplicado',
            DDITelefone__c = original.DDITelefone__c,
            DDDTelefone__c = original.DDDTelefone__c,
            Phone = original.Phone,
            MidiaAtual__c = 'Facebook Ads',
            LeadSource = 'Instagram'
        );

        List<Lead> reiterados = [SELECT Id, LastName FROM Lead WHERE DDITelefone__c = :original.DDITelefone__c AND DDDTelefone__c = :original.DDDTelefone__c AND Phone = :original.Phone];
        Assert.areEqual(1, reiterados.size(), 'Não deve haver Leads duplicados');
        Assert.areNotEqual(original.LastName, reiterados[0].LastName, 'LastName deve ter seu valor atualizado');
        Test.stopTest();
    }

    @isTest
    private static void reiterationCPFTest() {
        Test.startTest();
        Lead original = [SELECT Id, CPF__c, LastName FROM Lead LIMIT 1];

        insert new Lead(
            LastName = 'Duplicado',
            Email = 'duplicado@email.com',
            CPF__c = original.CPF__c,
            MidiaAtual__c = 'Facebook Ads',
            LeadSource = 'Instagram'
        );

        List<Lead> reiterados = [SELECT Id, LastName FROM Lead WHERE CPF__c = :original.CPF__c];
        Assert.areEqual(1, reiterados.size(), 'Não deve haver Leads duplicados');
        Assert.areNotEqual(original.LastName, reiterados[0].LastName, 'LastName deve ter seu valor atualizado');
        Test.stopTest();
    }

    @isTest
    private static void reiterationCNPJTest() {
        Test.startTest();
        Lead original = [SELECT Id, LastName, CNPJ__c FROM Lead LIMIT 1];

        insert new Lead(
            LastName = 'Duplicado',
            Email = 'duplicado@email.com',
            CNPJ__c = original.CNPJ__c,
            MidiaAtual__c = 'Facebook Ads',
            LeadSource = 'Instagram'
        );

        List<Lead> reiterados = [SELECT Id, LastName FROM Lead WHERE CNPJ__c = :original.CNPJ__c];
        Assert.areEqual(1, reiterados.size(), 'Não deve haver Leads duplicados');
        Assert.areNotEqual(original.LastName, reiterados[0].LastName, 'LastName deve ter seu valor atualizado');
        Test.stopTest();
    }
}