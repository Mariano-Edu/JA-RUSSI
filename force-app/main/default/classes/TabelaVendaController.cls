public with sharing class TabelaVendaController {
    @AuraEnabled
    public static String clonarTabela(Map<String, String> tabelaVendas, Id idTabela) {
        try {
            return TabelaVendaService.clonarTabela(tabelaVendas, idTabela);
        } catch (Exception e) {
            throw e;
        }    
    }

}