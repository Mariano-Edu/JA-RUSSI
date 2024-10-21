global class EmpreendimentoResponse {
    public Id id;
    public String razaoSocial;

    global EmpreendimentoResponse(Empreendimento__c e) {
        this.id = e.Id;
        this.razaoSocial = e.Name;
    } 
}