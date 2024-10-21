public without sharing class LeadSelector {
    public static List<Lead> obterLeadsPorIds(Set<Id> idsLeads) {
        return [
            SELECT 
                Name, 
                CanalAtendimento__c,
                Corretor__c, 
                FirstName, 
                LastName, 
                MobilePhone, 
                Email, 
                Status, 
                OwnerId, 
                Owner.Name
            FROM Lead 
            WHERE Id IN :idsLeads
        ];
    }

    public static List<Lead> obterLeadsPorInformacoesConcierge(String whereParams) {
        return Database.query(
            'SELECT ' +
                'Name, ' +
                'FirstName, ' +
                'LastName, ' +
                'Company, '+
                'CelularFormatado__c, '+
                'TelefoneFormatado__c, ' +
                'Email, ' +
                'Status, ' +
                'Owner.Name ' +
            'FROM Lead WHERE '+whereParams
        );
    }
}