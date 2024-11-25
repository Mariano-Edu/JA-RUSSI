public with sharing class Product2Helper {
    private static final Id VAGA_RECORD_TYPE_ID = Schema.SObjectType.Product2.getRecordTypeInfosByName()
    .get('Vaga')
    .getRecordTypeId();

    public static void handleAfterInsert(List<Product2> products) {
        createStandardPricebookEntries(products);
    }

    private static void createStandardPricebookEntries(List<Product2> products) {
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        Id standardPricebookId = getStandardPricebookId();

        for (Product2 iProduct : products) {
            standardPricebookEntries.add(new PricebookEntry(
                Product2Id = iProduct.Id,
                UnitPrice = iProduct.RecordTypeId == VAGA_RECORD_TYPE_ID 
                                                        ? (iProduct.ValorVaga__c != null
                                                            ? iProduct.ValorVaga__c 
                                                            : 0.0)
                                                        : iProduct.ValorDaUnidade__c,
                Pricebook2Id = standardPricebookId,
                IsActive = true
            ));
        }

        insert standardPricebookEntries;
    }

    public static Id getStandardPricebookId() {
        return Test.isRunningTest() 
            ? Test.getStandardPricebookId() 
            : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    }
}