public class AccountController {
    
    @AuraEnabled(cacheable = true)
    public static Map<String, Account> obterInfoContaPorAnaliseCredito(Id idAnaliseCredito) {
        return AccountService.obterInfoContaPorAnaliseCredito(idAnaliseCredito);
    }

    @AuraEnabled
    public static void atualizarValoresConta(Map<String, String> camposValores, Id idConta){
        AccountService.atualizarValoresConta(camposValores, idConta);
    }
}