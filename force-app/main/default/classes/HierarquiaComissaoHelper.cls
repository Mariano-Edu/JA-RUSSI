public class HierarquiaComissaoHelper {
    public static void handleBeforeInsert(List<HierarquiaComissao__c> hierarchies) {
        validateBeforeInsert(hierarchies);
    }

    private static void validateBeforeInsert(List<HierarquiaComissao__c> hierarchies) {
        Set<Id> idsComission = ObjectHelper.getLookUpId(hierarchies, 'TabelaComissao__c');

        Map<Id,TabelaComissao__c> comissions = new Map<Id,TabelaComissao__c>(
            TabelaComissaoDA.getTabelaComissaoById(
                new Set<String>{'Id', 'PercentualComissao__c', 'ValorPremio__c', 'TotalPremio__c', 'TotalPercentual__c'},
                idsComission
            )
        );

        Map<Id,Set<String>> comissionsRoles = getComissionsRoles(idsComission);

        for(HierarquiaComissao__c iHierachy : hierarchies) {
            TabelaComissao__c comission = comissions.get(iHierachy.TabelaComissao__c);

            if(comission.TotalPremio__c + iHierachy.ValorPremio__c > comission.ValorPremio__c) {
                iHierachy.addError('O valor de prêmio das hierarquias não podem ultrapassar o valor definido na tabela');
            }

            if(comission.TotalPercentual__c + iHierachy.PercentualComissao__c > comission.PercentualComissao__c) {
                iHierachy.addError('O percentual das hierarquias não podem ultrapassar o valor definido na tabela');
            }

            if(comissionsRoles.containsKey(iHierachy.TabelaComissao__c) && comissionsRoles.get(iHierachy.TabelaComissao__c).contains(iHierachy.Cargo__c)) {
                iHierachy.addError('Apenas um tipo de cargo pode ser cadastrado por tabela de comissão');
            }
        }
    }

    private static Map<Id,Set<String>> getComissionsRoles(Set<Id> idsComission) {
        Map<Id,Set<String>> comissionsRoles = new Map<Id,Set<String>>();

        List<HierarquiaComissao__c> hierarchies = HierarquiaComissaoDA.getHierarquiaComissaoByTabela(
            new Set<String>{'Cargo__c', 'TabelaComissao__c'},
            idsComission
        );

        for(HierarquiaComissao__c iHierachy : hierarchies) {
            Set<String> roles = !comissionsRoles.containsKey(iHierachy.TabelaComissao__c) 
                ? new Set<String>()
                : comissionsRoles.get(iHierachy.TabelaComissao__c);
            
            roles.add(iHierachy.Cargo__c);

            comissionsRoles.put(iHierachy.TabelaComissao__c, roles);
        }

        return comissionsRoles;
    }
}