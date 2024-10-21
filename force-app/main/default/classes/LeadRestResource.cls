/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 06-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@RestResource(urlMapping='/Lead/')
global with sharing class LeadRestResource {
    private static final String STATUS_FALHA = 'Falha';
    private static final String STATUS_SUCESSO = 'Sucesso';
    private static final Set<String> SET_UNIQUE_FIELDS = new Set<String>{'Email', 'MobilePhone', 'CPF__c', 'CNPJ__c', 'Phone'};

    @HttpGet
    global static List<RecordType> getRecordId() {
        return new List<RecordType> {
            new RecordType(
                Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pessoa Física').getRecordTypeId(),
                'Pessoa Física'
            ),

            new RecordType(
                Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pessoa Jurídica').getRecordTypeId(),
                'Pessoa Jurídica'
            )
        };
    }

    @HttpPost
    global static Response doPost(List<Lead> leads){
        RestResponse res = RestContext.response;

        if(isInvalidBody(leads)){
            res.statusCode = 400;

            return new Response(
                'Os leads passados possuem alguns dos seguintes campos duplicados: '+SET_UNIQUE_FIELDS,
                STATUS_FALHA
            );
        }

        Map<Id,Lead> duplicateLeads = findDuplicateRecords(leads);
        Set<Lead> leadsSet = new Set<Lead>(leads);
        Set<Id> idLeads = new Set<Id>();

        if(!duplicateLeads.isEmpty()){

            for(Id idLead : duplicateLeads.keySet()){
                leadsSet.remove(duplicateLeads.get(idLead));
            }

            idLeads.addAll(duplicateLeads.keySet());

            try{
                LeadAPIHelper.handleReiteration(duplicateLeads);
            }catch(DmlException e) {
                res.statusCode = 400;
                return new Response(e.getStackTraceString(), STATUS_FALHA);
            }
        }

        List<Lead> newLeads = new List<Lead>(leadsSet);

        LeadAPIHelper.setIterationFields(leads);

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        
        for (Lead lead : newLeads) {
            lead.setOptions(dmlOpts);
        }
    
        Database.SaveResult[] leadsInsertResults = Database.insert(newLeads, dmlOpts);

        CampaignResource.registerCampaign(newLeads);
        for (Database.SaveResult result : leadsInsertResults){
            if(!result.isSuccess()){
                for(Database.Error error : result.getErrors()){
                    res.statusCode = 400;
                    return new Response(error.getStatusCode() + ': ' + error.getMessage(), STATUS_FALHA);
                }
            }
        }

        idLeads.addAll(new Map<Id, Lead>(newLeads).keySet());
        res.addHeader('Content-Type', 'text/plain');
        res.statusCode = 200;
        return new Response(String.join(new List<Id>(idLeads), ', '), STATUS_SUCESSO);
    }

    private static Map<Id, Lead> findDuplicateRecords(List<Lead> leads){
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Set<Lead> duplicateLeads = new Set<Lead>();

        for(Integer i = leads.size() - 1; i >= 0; i--){
            List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(new List<Lead>{leads[i]});
            
            for (Datacloud.FindDuplicatesResult dupeResult : duplicateResults) {
                for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                            Lead dupe = (Lead) matchRec.getRecord();
                            leads[i].Id = dupe.Id;
                            leadMap.put(dupe.Id, leads[i]);
                            
                            System.debug(dupe);
                        }
                    }
                }
            }
        }


        return leadMap;
    }

    private static Boolean isInvalidBody(List<Lead> leads){
        for (Integer i = 0; i < leads.size(); i++) {
            for (Integer j = 0; j < leads.size(); j++) {
                if(i == j) continue;

                for(String kField : SET_UNIQUE_FIELDS){
                    if(ObjectHelper.isEqualField(leads[i], leads[j], kField)) return true;
                }
            }
        }

        return false;
    }



    global class Response {
        public String status;
        public String mensagem;

        public Response(String pMensagem, String pStatus){
            mensagem = pMensagem;
            status = pStatus;
        }
    }

    global class RecordType {
        public Id id;
        public String alias;
        
        public RecordType(Id pId, String pAlias) {
            id = pId;
            alias = pAlias;
        }
    }
}