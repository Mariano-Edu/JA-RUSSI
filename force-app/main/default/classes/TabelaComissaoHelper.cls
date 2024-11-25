public class TabelaComissaoHelper {
    public static void handleBeforeInsert(List<TabelaComissao__c> tables) {
        validateAssociation(tables);
    }

    private static void validateAssociation(List<TabelaComissao__c> tables) {
        Map<Id,Boolean> hasActiveTableMap = getActiveTableMap(tables);

        for (TabelaComissao__c iTable : tables) {
            if(!iTable.Ativa__c) {
                continue;
            }

            if(hasActiveTableMap.containsKey(iTable.TabelaVenda__c) && hasActiveTableMap.get(iTable.TabelaVenda__c)) {
                iTable.addError('A Tabela de vendas não pode ter mais de uma Tabela de Comissão ativa associada');
            }
        }
    }

    private static Map<Id,Boolean> getActiveTableMap(List<TabelaComissao__c> tables) {
        Map<Id,Boolean> hasActiveTable = new Map<Id,Boolean>();

        List<TabelaComissao__c> associatedTables = TabelaComissaoDA.getTabelaComissaoByTabelaVenda(
            new Set<String>{'Id', 'Ativa__c', 'TabelaVenda__c'},
            ObjectHelper.getLookUpId(tables, 'TabelaVenda__c')
        );

        for(TabelaComissao__c table : associatedTables) {
            if(!hasActiveTable.containsKey(table.TabelaVenda__c)) {
                hasActiveTable.put(table.TabelaVenda__c, false);
            }

            if(table.Ativa__c) {
                hasActiveTable.put(table.TabelaVenda__c, true);
            }
        }

        return hasActiveTable;
    }
}