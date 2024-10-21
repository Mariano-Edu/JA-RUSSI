public with sharing class TabelaVendasService {
    public static Id criarTabelaDaSimulacao(List<SeriePagamentos__c> seriesProposta, Id idCotacao, String nomeCotacao, TabelaVendas__c tabelaSelecionada){
        
        System.debug(idCotacao);
        System.debug(nomeCotacao);

        Integer periocidadeParcelaPos = Integer.valueOf(tabelaSelecionada.PeriodicidadeParcelaPos__c);
        // Integer periodicidadeParcela = Integer.valueOf(tabelaSelecionada.PeriodicidadeParcela__c);
        Integer periodicidadeParcela = 0;
        System.debug('tabela'+tabelaSelecionada);
        system.debug('PeriocidaPP = '+periocidadeParcelaPos);
        system.debug('PeriocidaP = '+periodicidadeParcela);

        if(periocidadeParcelaPos != 1 && periocidadeParcelaPos != 6 && periocidadeParcelaPos != 12) {
            periocidadeParcelaPos = 1;
        }
        
        if(periodicidadeParcela != 1 && periodicidadeParcela != 6 && periodicidadeParcela != 12) {
            periodicidadeParcela = 1;
        }

        tabelaVendas__c tabelaVendaCotacao = tabelaVendasSelector.buscarTabelaPorIdCotacao(idCotacao);
        
            if(tabelaVendaCotacao != null){
                List<SeriePagamentos__c> seriesTabelaCotacao = SeriePagamentoSelector.obterSeriePorIdTabelaVendas(tabelaVendaCotacao.Id);

                DELETE seriesTabelaCotacao;
                DELETE tabelaVendaCotacao;
            }
        RecordType recordType = [SELECT id, name FROM RecordType WHERE SObjectType = 'TabelaVendas__c' AND Name = 'Tabela de Proposta' LIMIT 1];

        TabelaVendas__c novaTabelaCotacao = new TabelaVendas__c();
        novaTabelaCotacao.Name = 'Simulação ' + nomeCotacao;
        novaTabelaCotacao.Cotacao__c = idCotacao;
        novaTabelaCotacao.RecordTypeId = recordType.Id;
        novaTabelaCotacao.PeriodicidadeParcelaPos__c = periocidadeParcelaPos;
        //novaTabelaCotacao.PeriodicidadeParcela__c = periodicidadeParcela;
        
        INSERT novaTabelaCotacao;

        for (SeriePagamentos__c serie : seriesProposta) {
            serie.TabelaVenda__c = novaTabelaCotacao.Id;
        }
        System.debug(seriesProposta);

        INSERT seriesProposta;

        return novaTabelaCotacao.Id;
    }
}