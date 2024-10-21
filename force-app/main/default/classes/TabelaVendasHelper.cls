public with sharing class TabelaVendasHelper {
   
    public static void inserirUnidadesTabelas(List<TabelaVendas__c> tabelas) {
        Set<Id> empreendimentoIds = new Set<Id>();
        Set<Id> tabelaVendasIds = new Set<Id>();

        for (TabelaVendas__c tab : tabelas) {
            if (tab.Empreendimento__c != null) {
                empreendimentoIds.add(tab.Empreendimento__c);
            }
            tabelaVendasIds.add(tab.Id);
        }

        Map<Id, Product2> unidades = ProdutoSelector.obterUnidadesRelacionadas(empreendimentoIds);
        Map<Id, UnidadeTabelaVendas__c> unidadesExistentes = UnidadeTabelaSelector.obterUnidadesTabelaExistentes(tabelaVendasIds);


        List<UnidadeTabelaVendas__c> unidadesParaAtualizar = new List<UnidadeTabelaVendas__c>();
        List<UnidadeTabelaVendas__c> unidadesParaInserir = new List<UnidadeTabelaVendas__c>();
        List<UnidadeTabelaVendas__c> unidadesParaExcluir = new List<UnidadeTabelaVendas__c>();

        Set<Id> idsExistentesParaManter = new Set<Id>();

        for (TabelaVendas__c tab : tabelas) {
            for (Product2 unidade : unidades.values()) {
                Boolean found = false;

                for (UnidadeTabelaVendas__c existente : unidadesExistentes.values()) {
                    if (existente.Unidade__c == unidade.Id && existente.TabelaVenda__c == tab.Id) {
                        existente.Name = unidade.Name;
                        existente.PrecoLista__c = unidade.PrecoLista__c;
                        existente.CoeficienteTabela__c = unidade.Coeficiente__c;
                        existente.MetragemUnidade__c = unidade.MetragemTotal__c;
                        unidadesParaAtualizar.add(existente);
                        idsExistentesParaManter.add(existente.Id);
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    UnidadeTabelaVendas__c novaUnidadeTabela = new UnidadeTabelaVendas__c();
                    novaUnidadeTabela.Name = unidade.Name;
                    novaUnidadeTabela.PrecoLista__c = unidade.PrecoLista__c;
                    novaUnidadeTabela.CoeficienteTabela__c = unidade.Coeficiente__c;
                    novaUnidadeTabela.MetragemUnidade__c = unidade.MetragemTotal__c;
                    novaUnidadeTabela.Unidade__c = unidade.Id;
                    novaUnidadeTabela.TabelaVenda__c = tab.Id;
                    unidadesParaInserir.add(novaUnidadeTabela);
                }
            }
        }

        for (UnidadeTabelaVendas__c existente : unidadesExistentes.values()) {
            if (!idsExistentesParaManter.contains(existente.Id)) {
                unidadesParaExcluir.add(existente);
            }
        }

        if (!unidadesParaAtualizar.isEmpty()) {
            update unidadesParaAtualizar;
        }
        if (!unidadesParaInserir.isEmpty()) {
            insert unidadesParaInserir;
        }
        if (!unidadesParaExcluir.isEmpty()) {
            delete unidadesParaExcluir;
        }
    }

}