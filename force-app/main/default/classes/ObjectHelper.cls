public with sharing class ObjectHelper {
    public static Set<Id> getLookUpId(List<SObject> objects, String field){
        Set<Id> setId = new Set<Id>();

        for(SObject iObject : objects){
            if(iObject.get(field) != null){
                setId.add((Id) iObject.get(field));
            }
        }

        return setId;
    }

    public static Set<String> getFieldValuesFromList(List<SObject> objects, String field) {
        Set<String> setString = new Set<String>();

        for(SObject iObject : objects){
            if(iObject.get(field) != null){
                setString.add((String) iObject.get(field));
            }
        }

        return setString;
    }

    public static Set<Id> getIdValuesFromList(List<SObject> objects) {
        Set<Id> setId = new Set<Id>();

        for(SObject iObject : objects){
            if(iObject.Id != null){
                setId.add((Id) iObject.Id);
            }
        }

        return setId;
    }

    public static Boolean containsAny(Set<String> set1, Set<String> set2) {
        for (String i : set1) {
            if (set2.contains(i)) {
                return true;
            }
        }

        return false;
    }

    public static Boolean isEqualField(SObject iObject, SObject jObject, String field){
        return String.isNotEmpty((String) iObject.get(field)) && iObject.get(field) == jObject.get(field);
    }

    public static Boolean isEqualField(Set<String> fields, List<SObject> iObjects, Map<Id, SObject> jOldObjects) {

        if (jOldObjects == null) {
            return false;
        }

        for (SObject iObject : iObjects) {
            for (String iField : fields) {
                if ((iObject.get(iField)) != null && (jOldObjects.get(iObject.Id).get(iField) != iObject.get(iField))) {
                    return false;
                }
            }
        }
        
        return true;
    }

    public static void updateFields(SObject iLead, SObject jLead, Set<String> fields){
        for(String field : fields){
            if(iLead.get(field) != null && iLead.get(field) != jLead.get(field)){
                jLead.put(field, iLead.get(field));
            }
        }
    }

    public static Set<String> getFieldSet(String objectName){
        SObjectType leadType = Schema.getGlobalDescribe().get(objectName);
        Set<String> camposLead = new Set<String>();

        Map<String, Schema.SObjectField> mfields = leadType.getDescribe().fields.getMap();


        for(String campo : mfields.keySet()){
            camposLead.add(campo);
        }

        return camposLead;
    }

    public static String getPickListLabel(String objectApiName, String fieldApiName, String value) {
        Schema.DescribeFieldResult results = Schema.getGlobalDescribe().get(objectApiName)
            .getDescribe()
            .fields.getMap()
            .get(fieldApiName)
            .getDescribe();

        for(Schema.PicklistEntry entry : results.getPicklistValues()) {
            if(entry.getValue().equals(value)) {
                return entry.getLabel();
            }
        }

        return null;
    }

    public static List<String> getPickListValuesList(String objectApiName, String fieldApiName) {
        List<String> pickListValues = new List<String>();

        Schema.DescribeFieldResult results = Schema.getGlobalDescribe().get(objectApiName)
            .getDescribe()
            .fields.getMap()
            .get(fieldApiName)
            .getDescribe();

        for(Schema.PicklistEntry entry : results.getPicklistValues()) {
            pickListValues.add(entry.getValue());
        }

        return pickListValues;
    }
}