public class AccountSelector {
    public static Account obterInfoContaPorId(Id idConta) {
        return [SELECT 
            Name, FirstName, LastName, CNPJ__c, Nome_da_Mae__c,
            CPF__c, EstadoEmissor__c, Nacionalidade__c, Naturalidade__c,
            Nome_do_Pai__c, DataDeNascimento__c, DataDeEmissao__c, OrgaoEmissor__c,
            EstadoCivil__c, Data_de_Casamento__c, Conjuge__pc, RecordType.DeveloperName,
            Estado_de_Nascimento__c, NumeroDoDocumento__c, Celular__c FROM Account WHERE Id = :idConta];
    }

    public static Account obterContaPorId(Id idConta) {
        return [SELECT Id FROM Account WHERE Id = :idConta];
    }
}