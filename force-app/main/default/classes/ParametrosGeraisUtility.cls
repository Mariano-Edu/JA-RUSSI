public without sharing class ParametrosGeraisUtility {

    public static Set<String> FIELD_SET = Schema.getGlobalDescribe().get('Parametro_Geral__c').getDescribe().fields.getMap().keySet();

    /**
     * Dynamic query for Parametro_Geral__c
     * Parameters exemple: findDynamic(new Set<String>{'Id', 'Name'}, new Set<String>{'Name = \'' + name + '\''});
     * 
     */
    public static List<Parametro_Geral__c> findDynamic(Set<String> fields, Set<String> whereClause) {

        if (whereClause == null || whereClause.isEmpty()) {
            return Database.query(
                String.format(
                    'SELECT {0} FROM Parametro_Geral__c', 
                    new List<String>{ String.join(new List<String>(fields),',') }
                )
            );
        }

        return Database.query(
            String.format(
                'SELECT {0} FROM Parametro_Geral__c WHERE {1}', 
                new List<String>{ String.join(new List<String>(fields),','), String.join(new List<String>(whereClause), '') }
            )
        );
    }

    public static Map<String, List<Parametro_Geral__c>> getMapDynamic(Set<String> fields, Set<String> whereClause, String keyField) {

        Map<String, List<Parametro_Geral__c>> parameterByDeveloperNameMap = new Map<String, List<Parametro_Geral__c>>();

        for (Parametro_Geral__c parameter : findDynamic(fields, whereClause)) {
            String keyFieldValue = (String) parameter.get(keyField);
            if (keyFieldValue.startsWith('012')) {
                keyFieldValue = getRTDeveloperName(keyFieldValue);
            }
            if (!parameterByDeveloperNameMap.containsKey(keyFieldValue)) {
                parameterByDeveloperNameMap.put(keyFieldValue, new List<Parametro_Geral__c>());
            } 
            parameterByDeveloperNameMap.get(keyFieldValue).add(parameter);
        }
        return parameterByDeveloperNameMap;
    }

    public static String getRTDeveloperName(Id recordTypeId) {
        return Parametro_Geral__c.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
    }
}