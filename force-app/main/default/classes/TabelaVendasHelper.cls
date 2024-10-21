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
                        existente.PrecoLista__c = unidade.ValorDaUnidade__c;
                        existente.CoeficienteTabela__c = unidade.Coeficiente__c;
                        existente.MetragemUnidade__c = unidade.MetragemDaUnidadeM__c;
                        unidadesParaAtualizar.add(existente);
                        idsExistentesParaManter.add(existente.Id);
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    UnidadeTabelaVendas__c novaUnidadeTabela = new UnidadeTabelaVendas__c();
                    novaUnidadeTabela.Name = unidade.Name;
                    novaUnidadeTabela.PrecoLista__c = unidade.ValorDaUnidade__c;
                    novaUnidadeTabela.CoeficienteTabela__c = unidade.Coeficiente__c;
                    novaUnidadeTabela.MetragemUnidade__c = unidade.MetragemDaUnidadeM__c;
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
    
    public static void validarTipoVenda(List<TabelaVendas__c> tabelas) {
        Set<String> tipoVenda = new Set<String>();
        Set<String> setNome = new Set<String>();
        Set<Id> setEmpreendimento = new Set<Id>();
        
        
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Name != null) {
                setNome.add(iTab.Name);
            }
            if (iTab.Empreendimento__c != null) {
                setEmpreendimento.add(iTab.Empreendimento__c);
            }
            if (iTab.TipoVenda__c != null) {
                tipoVenda.add(iTab.TipoVenda__c);
            }
        }
        
        List<TabelaVendas__c> tipoVendaTabela = [
            SELECT 
                Id, 
                Name, 
                TipoVenda__c,
                Empreendimento__c
            FROM TabelaVendas__c
            WHERE 
                Name IN :setNome 
                OR Empreendimento__c IN :setEmpreendimento
                OR TipoVenda__c IN :tipoVenda
        ];
        
        
        List<Opportunity> tipoVendaOportunidade = [
            SELECT 
                Id, 
                Name, 
                EmpreendimentodeInteresse__c
            FROM Opportunity
            WHERE 
                EmpreendimentodeInteresse__c IN :setEmpreendimento
        ];
        
        
        Map<Id, String> empreendimentoTabelaMap = new Map<Id, String>();
        
        for (TabelaVendas__c tabela : tipoVendaTabela) {
            if (tabela.Empreendimento__c != null) {
                empreendimentoTabelaMap.put(tabela.Empreendimento__c, tabela.TipoVenda__c);
            }
        }
        
        for (Opportunity opp : tipoVendaOportunidade) {
            if (opp.EmpreendimentodeInteresse__c != null && empreendimentoTabelaMap.containsKey(opp.EmpreendimentodeInteresse__c)) {
                String tipoVendaTab = empreendimentoTabelaMap.get(opp.EmpreendimentodeInteresse__c);
                
                
                for (TabelaVendas__c tabela : tabelas) {
                    if (tabela.Empreendimento__c == opp.EmpreendimentodeInteresse__c) {
                        if (tabela.TipoVenda__c == tipoVendaTab && tabela.Id == null) {
                            tabela.addError('Já existe uma tabela com o mesmo tipo de venda para esse empreendimento.');
                        }
                    }
                }
            }
        }
        
    }
    
    public static void validarTabelaIguais(List<TabelaVendas__c> tabelas) {
        Set<String> setNome = new Set<String>();
        Set<Id> setEmpreendimento = new Set<Id>();
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Name != null) {
                setNome.add(iTab.Name);
            }
            if (iTab.Empreendimento__c != null) {
                setEmpreendimento.add(iTab.Empreendimento__c);
            }
        }
        List<TabelaVendas__c> existingTabelas = [
            SELECT 
            Id, 
            Name, 
            Ativo__c, 
            VigenciaInicio__c, 
            VigenciaFim__c, 
            Empreendimento__c
            FROM TabelaVendas__c
            WHERE 
            Name IN :setNome 
            OR 
            Empreendimento__c IN :setEmpreendimento
        ];
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Name == null) {
                continue;
            }
            
            if (itab.Id == Null) {
                
                for (TabelaVendas__c existingTab : existingTabelas) {
                    if (existingTab.Name == iTab.Name && existingTab.Id != iTab.Id) {
                        iTab.addError('Já existe uma tabela de vendas com este nome.');
                        break;
                    }
                }
                
                for (TabelaVendas__c existingTab : existingTabelas) {
                    if (existingTab.Empreendimento__c == iTab.Empreendimento__c && existingTab.Id != iTab.Id) {
                        
                        if (iTab.VigenciaInicio__c <= existingTab.VigenciaFim__c && iTab.VigenciaFim__c >= existingTab.VigenciaInicio__c) {
                            iTab.addError('As datas de vigência não podem se sobrepor às datas de uma tabela existente para o mesmo empreendimento com o mesmo tipo de venda.');
                            break;
                        }
                        if (iTab.Ativo__c == true && iTab.id == null) {
                            iTab.addError('A tabela só deve ser ativada após ela ser criada.');
                            break;
                        }
                    }
                }
            }
        }
    }
    
    public static void clonarSeriePagamento(List<TabelaVendas__c> tabelas) {
        System.debug('Iniciando clonarSeriePagamento');
        
        Set<String> setNome = new Set<String>();
        Set<Id> setEmpreendimento = new Set<Id>();
        
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Name != null) {
                setNome.add(iTab.Name);
            }
            if (iTab.Empreendimento__c != null) {
                setEmpreendimento.add(iTab.Empreendimento__c);
            }
        }
        System.debug('setNome: ' + setNome);
        System.debug('setEmpreendimento: ' + setEmpreendimento);
        
        List<TabelaVendas__c> existingTabelas = [
            SELECT 
            Id, 
            Name, 
            Ativo__c, 
            OrigemTabelaDeVenda__c, 
            Empreendimento__c
            FROM TabelaVendas__c
            WHERE (Name IN :setNome OR Empreendimento__c IN :setEmpreendimento) AND Ativo__c = true
        ];
        System.debug('existingTabelas: ' + existingTabelas);
        
        Map<Id, Id> empreendimentoToActiveTabelaMap = new Map<Id, Id>();
        Map<Id, String> tabelaIdToNameMap = new Map<Id, String>();
        
        for (TabelaVendas__c existingTabela : existingTabelas) {
            empreendimentoToActiveTabelaMap.put(existingTabela.Empreendimento__c, existingTabela.Id);
            tabelaIdToNameMap.put(existingTabela.Id, existingTabela.Name);
        }
        System.debug('empreendimentoToActiveTabelaMap: ' + empreendimentoToActiveTabelaMap);
        System.debug('tabelaIdToNameMap: ' + tabelaIdToNameMap);
        
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Id == null && empreendimentoToActiveTabelaMap.containsKey(iTab.Empreendimento__c)) {
                iTab.OrigemTabelaDeVenda__c = empreendimentoToActiveTabelaMap.get(iTab.Empreendimento__c);
            } else if (iTab.Ativo__c == true) {
                iTab.OrigemTabelaDeVenda__c = iTab.Id;
            }
        }
        System.debug('tabelas após ajuste de OrigemTabelaDeVenda__c: ' + tabelas);
        
        Set<Id> idsDeOrigem = new Set<Id>();
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.OrigemTabelaDeVenda__c != null) {
                idsDeOrigem.add(iTab.OrigemTabelaDeVenda__c);
            }
        }
        System.debug('idsDeOrigem: ' + idsDeOrigem);
        
        List<SeriePagamentos__c> seriesDePagamentos = [
            SELECT 
            Id, 
            TabelaVenda__c, 
            TipoCondicao__c,
            InicioPagamento__c,
            QuantidadeParcelas__c,
            ValorTotal__c
            FROM SeriePagamentos__c 
        ];
        System.debug('seriesDePagamentos: ' + seriesDePagamentos);
        
        Map<Id, List<SeriePagamentos__c>> tabelaToSeriesMap = new Map<Id, List<SeriePagamentos__c>>();
        for (SeriePagamentos__c serie : seriesDePagamentos) {
            if (!tabelaToSeriesMap.containsKey(serie.TabelaVenda__c)) {
                tabelaToSeriesMap.put(serie.TabelaVenda__c, new List<SeriePagamentos__c>());
            }
            tabelaToSeriesMap.get(serie.TabelaVenda__c).add(serie);
        }
        System.debug('tabelaToSeriesMap: ' + tabelaToSeriesMap);
        
        List<SeriePagamentos__c> novasSeries = new List<SeriePagamentos__c>();
        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.OrigemTabelaDeVenda__c != null && tabelaToSeriesMap.containsKey(iTab.OrigemTabelaDeVenda__c)) {
                List<SeriePagamentos__c> seriesRelacionadas = tabelaToSeriesMap.get(iTab.OrigemTabelaDeVenda__c);
                for (SeriePagamentos__c serie : seriesRelacionadas) {
                    if (iTab.OrigemTabelaDeVenda__c != iTab.Id) {
                        SeriePagamentos__c novaSerie = new SeriePagamentos__c();
                        novaSerie.TabelaVenda__c = iTab.Id;
                        if (String.isBlank(serie.OrigemSeriePagamento__c)) {
                            novaSerie.OrigemSeriePagamento__c = tabelaIdToNameMap.get(serie.TabelaVenda__c);
                        } else {
                            novaSerie.OrigemSeriePagamento__c = serie.OrigemSeriePagamento__c;
                        }
                        novaSerie.TipoCondicao__c = serie.TipoCondicao__c;
                        novaSerie.InicioPagamento__c = serie.InicioPagamento__c;
                        novaSerie.QuantidadeParcelas__c = serie.QuantidadeParcelas__c;
                        novaSerie.ValorTotal__c = serie.ValorTotal__c;
                        novasSeries.add(novaSerie);
                    }
                }
            }
        }
        System.debug('novasSeries: ' + novasSeries);
        
        if (!novasSeries.isEmpty()) {
            insert novasSeries;
            System.debug('Novas séries de pagamento inseridas: ' + novasSeries);
        }
    }
}