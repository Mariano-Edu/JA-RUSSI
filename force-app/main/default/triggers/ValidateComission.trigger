trigger ValidateComission on HierarquiaDaComissao__c (before insert, before update) {

    Map<Id, Map<String, Decimal>> somaPercentuaisPorTabela = new Map<Id, Map<String, Decimal>>();

   
    for (HierarquiaDaComissao__c hierarquia : Trigger.new) {
        if (hierarquia.TabelaDeComissao__c != null) {
            if (!somaPercentuaisPorTabela.containsKey(hierarquia.TabelaDeComissao__c)) {
                somaPercentuaisPorTabela.put(hierarquia.TabelaDeComissao__c, new Map<String, Decimal>{
                    'Imobiliária' => 0,
                    'Incorporadora' => 0
                });
            }

            String grupo = hierarquia.Role__c.contains('Imobiliária') ? 'Imobiliária' : 'Incorporadora';
            Decimal percentualAtual = hierarquia.Comission__c;

           
            if (Trigger.isUpdate && Trigger.oldMap.containsKey(hierarquia.Id)) {
                HierarquiaDaComissao__c oldHierarquia = Trigger.oldMap.get(hierarquia.Id);
                Decimal percentualAntigo = oldHierarquia.Comission__c;
                
                
                String grupoAntigo = oldHierarquia.Role__c.contains('Imobiliária') ? 'Imobiliária' : 'Incorporadora';
                somaPercentuaisPorTabela.get(hierarquia.TabelaDeComissao__c).put(
                    grupoAntigo,
                    somaPercentuaisPorTabela.get(hierarquia.TabelaDeComissao__c).get(grupoAntigo) - percentualAntigo
                );
            }

           
            somaPercentuaisPorTabela.get(hierarquia.TabelaDeComissao__c).put(
                grupo,
                somaPercentuaisPorTabela.get(hierarquia.TabelaDeComissao__c).get(grupo) + percentualAtual
            );
        }
    }

   
    List<HierarquiaDaComissao__c> registrosExistentes = [
        SELECT TabelaDeComissao__c, Role__c, Comission__c
        FROM HierarquiaDaComissao__c
        WHERE TabelaDeComissao__c IN :somaPercentuaisPorTabela.keySet()
    ];

    
    for (HierarquiaDaComissao__c registro : registrosExistentes) {
        String grupo = registro.Role__c.contains('Imobiliária') ? 'Imobiliária' : 'Incorporadora';
        Decimal percentualExistente = registro.Comission__c;

        somaPercentuaisPorTabela.get(registro.TabelaDeComissao__c).put(
            grupo,
            somaPercentuaisPorTabela.get(registro.TabelaDeComissao__c).get(grupo) + percentualExistente
        );
    }

    
    List<TabelaDeComissao__c> tabelasComissao = [
        SELECT Id, RealStateComissionPercentage__c, RealStateDeveloperComissionPercentage__c, PrizePercentage__c
        FROM TabelaDeComissao__c
        WHERE Id IN :somaPercentuaisPorTabela.keySet()
    ];

  
    for (TabelaDeComissao__c tabela : tabelasComissao) {
        Map<String, Decimal> somaPorGrupo = somaPercentuaisPorTabela.get(tabela.Id);

        Decimal limiteImobiliaria = (tabela?.RealStateComissionPercentage__c ?? 0) + (tabela.PrizePercentage__c ?? 0);
        Decimal limiteIncorporadora = (tabela?.RealStateDeveloperComissionPercentage__c ?? 0) + (tabela?.PrizePercentage__c ?? 0);

        if (somaPorGrupo.get('Imobiliária') > limiteImobiliaria) {
            for (HierarquiaDaComissao__c hierarquia : Trigger.new) {
                if (hierarquia.TabelaDeComissao__c == tabela.Id && hierarquia.Role__c.contains('Imobiliária')) {
                    hierarquia.addError(
                        'A soma dos Percentuais de Comissão para cargos "Imobiliária" excede o limite de ' +
                        limiteImobiliaria + '% (incluindo o prêmio) definido na Tabela de Comissão.'
                    );
                }
            }
        }

        if (somaPorGrupo.get('Incorporadora') > limiteIncorporadora) {
            for (HierarquiaDaComissao__c hierarquia : Trigger.new) {
                if (hierarquia.TabelaDeComissao__c == tabela.Id && !hierarquia.Role__c.contains('Imobiliária')) {
                    hierarquia.addError(
                        'A soma dos Percentuais de Comissão para cargos "Incorporadora" excede o limite de ' +
                        limiteIncorporadora + '% (incluindo o prêmio) definido na Tabela de Comissão.'
                    );
                }
            }
        }
    }
}