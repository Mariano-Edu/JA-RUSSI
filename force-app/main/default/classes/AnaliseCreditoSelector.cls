public class AnaliseCreditoSelector {
    public static AnaliseDeCredito__c obterAnaliseCreditoPorId(Id idAnaliseCredito) {
        return [SELECT Oportunidade__c FROM AnaliseDeCredito__c WHERE Id = :idAnaliseCredito];
    }
}