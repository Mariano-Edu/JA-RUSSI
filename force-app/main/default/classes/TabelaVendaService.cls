public class TabelaVendaService {
    public static Id clonarTabela(Map<String,String> tabelaClone, Id idTabela) {
        System.debug(tabelaClone);

        TabelaVendas__c tabelaOriginal = TabelaVendasSelector.getTabelaVendasPorId(idTabela);
        TabelaVendas__c tabelaVendaClone = tabelaOriginal.clone(false, true, false, false);
        
        tabelaVendaClone.Name = tabelaClone.get('Name');
        tabelaVendaClone.VigenciaInicio__c = Date.parse(tabelaClone.get('VigenciaInicio__c'));
        tabelaVendaClone.VigenciaFim__c = Date.parse(tabelaClone.get('VigenciaFim__c'));
        tabelaVendaClone.PercentualDeAcrescimo__c = Decimal.valueOf(tabelaClone.get('PercentualDeAcrescimo__c'));
        
        insert tabelaVendaClone;
        return tabelaVendaClone.Id;
        //return null;
    }
}