public class TabelaVendaService {
    public static Id clonarTabela(Map<String,String> tabelaClone, Id idTabela) {
        System.debug(tabelaClone);

        TabelaVendas__c tabelaOriginal = TabelaVendasSelector.getTabelaVendasPorId(idTabela);
            
        if (tabelaOriginal == null) {
           throw new AuraHandledException('Tabela de Vendas original não encontrada.');
        }
        
        TabelaVendas__c tabelaVendaClone = tabelaOriginal.clone(false, true, false, false);
        
            tabelaVendaClone.Name = tabelaClone.get('Name');
            tabelaVendaClone.VigenciaInicio__c = Date.valueOf(tabelaClone.get('VigenciaInicio__c'));
            tabelaVendaClone.VigenciaFim__c = Date.valueOf(tabelaClone.get('VigenciaFim__c'));
            tabelaVendaClone.PercentualDeAcrescimo__c = tabelaClone.get('PercentualDeAcrescimo__c') != null ? Decimal.valueOf(tabelaClone.get('PercentualDeAcrescimo__c')) : 0;        
            tabelaVendaClone.Clonado__c = true;
            tabelaVendaClone.Ativo__c = false;
            tabelaVendaClone.ClonadoPor__c = UserInfo.getName();
            tabelaVendaClone.OrigemTabelaDeVenda__c = tabelaOriginal.Id;
            tabelaVendaClone.DataDaClonagem__c = Date.today();
       
        List<TabelaVendas__c> tabelasParaValidacao = new List<TabelaVendas__c>{ tabelaVendaClone };

            TabelaVendasHelper.validarTipoVenda(tabelasParaValidacao);
            TabelaVendasHelper.validarTabelaIguais(tabelasParaValidacao, true);
       

            insert tabelaVendaClone;
       

            clonarSeries(idTabela, tabelaVendaClone.Id);
         
        return tabelaVendaClone.Id;
    }

    private static void clonarSeries(Id idTabelaOriginal, Id idTabelaClonada) {
        List<SeriePagamentos__c> seriesOriginais = TabelaVendasSelector.getSeriesPagamentosPorTabela(idTabelaOriginal);
        System.debug(seriesOriginais);
        
        List<SeriePagamentos__c> seriesClonadas = new List<SeriePagamentos__c>();
        
        for (SeriePagamentos__c serieOriginal : seriesOriginais) {
            SeriePagamentos__c serieClonada = serieOriginal.clone(false, true, false, false);
        
            serieClonada.TabelaVenda__c = idTabelaClonada;
            seriesClonadas.add(serieClonada);
        }
        
        insert seriesClonadas;

        
    }
}