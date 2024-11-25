public with sharing class SignatariosService {
    public static void createSignatariosByOppId(Id oppId){
        List<Signatario__c> signers  = new List<Signatario__c>();
        for(Comprador__c comp : CompradorSelector.obterCompradoresPorOportunidade(oppId)){
            Signatario__c signer = new Signatario__c();
            signer.TipoSignatario__c = comp.TipoParticipante__c; 
            signer.Name = comp.Conta__r.Name; 
            signer.Email__c = comp.Conta__r.PersonEmail;
            signer.Contrato__c = comp.Oportunidade__r.ContractId; 
            signers.add(signer);            
        }
        insert signers;
    }
}