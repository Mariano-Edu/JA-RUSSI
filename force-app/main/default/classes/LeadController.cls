public without sharing class LeadController {
    
    @AuraEnabled(cacheable = true)
    public static Map<String, String>
     getMotivosPerda() {
        return 
        LeadService.obterMotivos();
    }

    @AuraEnabled
    public static void alterarStatusParaPerdido(Id idLead, String motivo) {LeadService.alterarStatusParaPerdido(idLead, motivo);}
}