public with sharing class TabelaVendaController {
    @AuraEnabled
    public static Id clonarTabela(Map<String,String> tabelaVendas, Id idTabela) {
        return TabelaVendaService.clonarTabela(tabelaVendas, idTabela);
    }
}