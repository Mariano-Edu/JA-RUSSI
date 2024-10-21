public class PicklistHelper {
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
}