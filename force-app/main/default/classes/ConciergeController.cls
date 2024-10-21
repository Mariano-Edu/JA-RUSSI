public class ConciergeController {
    @AuraEnabled(cacheable = true)
    public static Map<String, String> obterCanaisAtendimento() {
        return ConciergeService.obterCanaisAtendimento();
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> obterOrigens() {
        return ConciergeService.obterOrigens();
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> obterDDIs() {
        return ConciergeService.obterDDIs();
    }

    @AuraEnabled(cacheable = true)
    public static Map<String,String> obterMidias() {
        return ConciergeService.obterMidias();
    }

    @AuraEnabled
    public static String obterLeadsPorInformacoesConcierge(Map<String, String> formulario) {
        return ConciergeService.obterLeadsPorInformacoesConcierge(formulario);
    }

    @AuraEnabled
    public static Id criarLead(Map<String, String> formulario) {
        try {
            return ConciergeService.criarLead(formulario); 
        } catch(Exception e) {
            System.debug('Erro ao criar lead: ' + e.getMessage());
            throw e;
        }
    }
}