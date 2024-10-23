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
                        if (tabela.TipoVenda__c == tipoVendaTab && tabela.Id == null && tabela.Ativo__c == true) {
                            throw new AuraHandledException('Já existe uma tabela com o mesmo tipo de venda para esse empreendimento.');
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
    

        if (existingTabelas.isEmpty()) {
            return;

        }

        for (TabelaVendas__c iTab : tabelas) {
            if (iTab.Name == null) {
                continue;
            }
    
            if (iTab.Id == null) {
                if (!existingTabelas.isEmpty()) {
                    for (TabelaVendas__c existingTab : existingTabelas) {
                        if (existingTab.Name == iTab.Name && existingTab.Id != iTab.Id) {
                            throw new AuraHandledException('Já existe uma tabela de vendas ativa com este nome.');
                        }
                    }
    
                    for (TabelaVendas__c existingTab : existingTabelas) {
                        if (existingTab.Empreendimento__c == iTab.Empreendimento__c && existingTab.Id != iTab.Id) {
                            if (iTab.VigenciaInicio__c <= existingTab.VigenciaFim__c && iTab.VigenciaFim__c >= existingTab.VigenciaInicio__c) {
                                throw new AuraHandledException('As datas de vigência não podem se sobrepor às datas de uma tabela existente para o mesmo empreendimento com o mesmo tipo de venda.');
                            }
                            if (iTab.Ativo__c == true && iTab.Id == null) {
                                throw new AuraHandledException('A tabela só deve ser ativada após ela ser criada.');
                            }
                        }
                    }
                }
            }
        }
    }
}