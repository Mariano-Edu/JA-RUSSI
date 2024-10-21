public class LeadDTO {
    public String id;
    public String nome;
    public String primeiroNome;
    public String sobrenome;
    public String email;
    public String celular;
    public String status;
    public String proprietario;
    public String telefone;
    public String canalAtendimento;
    public String origem;
    private String empresa;

    public LeadDTO(Lead lead) {
        Map<String, Object> camposLeadPorNomeAPI = lead.getPopulatedFieldsAsMap();

        this.id = lead.Id;
        this.nome = camposLeadPorNomeAPI.containsKey('Name') ? lead.Name : null;
        this.primeiroNome = camposLeadPorNomeAPI.containsKey('FirstName') ? lead.FirstName : null;
        this.sobrenome = camposLeadPorNomeAPI.containsKey('LastName') ? lead.LastName : null;
        this.celular = camposLeadPorNomeAPI.containsKey('CelularFormatado__c') ? lead.CelularFormatado__c : null;
        this.telefone = camposLeadPorNomeAPI.containsKey('TelefoneFormatado__c') ? lead.TelefoneFormatado__c : null;
        this.origem = camposLeadPorNomeAPI.containsKey('LeadSource') ? Lead.LeadSource : null;
        this.email = camposLeadPorNomeAPI.containsKey('Email') ? lead.Email : null;
        this.empresa = camposLeadPorNomeAPI.containsKey('Company') ? lead.Company : null;

        this.status = camposLeadPorNomeAPI.containsKey('Status') 
            ? PicklistHelper.getPickListLabel('Lead', 'Status', lead.Status) 
            : null;
            
        this.proprietario = lead.Owner.Name;
    }
}