public with sharing class GeracaoContratoService {
   @AuraEnabled
   public static void generateContract(Id recordId){
        Contract ctt = new Contract();
        ctt.AccountId = 
        ctt.Status = 'Draft';
        ctt.StartDate = Date.today(); 
        insert ctt;

        update new Opportunity(Id = recordId, ContractId = ctt.Id);
   }
}