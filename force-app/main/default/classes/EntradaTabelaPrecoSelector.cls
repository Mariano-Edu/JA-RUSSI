public with sharing class EntradaTabelaPrecoSelector {
    public static PricebookEntry getEntradaTabelaPrecoByProdutoId(Id id){
        return [SELECT Id, UnitPrice from PricebookEntry where Product2Id =: id];
    }
}