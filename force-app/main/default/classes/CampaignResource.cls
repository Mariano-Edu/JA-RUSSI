/**
 * @description       : Esta classe lida com o registro de leads em campanhas como Campaign Members.
**/
public with sharing class CampaignResource {

    public static void registerCampaign(List<Lead> leads){
        
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
        Map<String, CampaignMember> mapExistingCM = getExistingCampaignMember(leads);
        
        for (Lead leadAtual : leads) {
            if (!String.isBlank(leadAtual.Campanha__c) && !mapExistingCM.containsKey(getCMKey(leadAtual))) {
                CampaignMember campanhaAtual = new CampaignMember();
                campanhaAtual.CampaignId = leadAtual.Campanha__c;  
                campanhaAtual.LeadId = leadAtual.Id;
                campanhaAtual.Status = 'Sent';
                newCampaignMembers.add(campanhaAtual);
            }
        }

        Database.SaveResult[] campaignInsertResults = Database.insert(newCampaignMembers);
    }

    private static Map<String, CampaignMember> getExistingCampaignMember(List<Lead> leads) {
        Map<String, CampaignMember> result = new Map<String, CampaignMember>();
        Set<Id> setLeadId = new Set<Id>();
        Set<Id> setCampaignId = new Set<Id>();
        for (Lead iLead : leads) {
            setLeadId.add(iLead.Id);
            setCampaignId.add(iLead.Campanha__c);
        }
        List<CampaignMember> lstCM = CampaignMemberDA.getByLeadCampaign(new Set<String>{'Id', 'LeadId', 'CampaignId'}, setLeadId, setCampaignId);
        for (CampaignMember iCM : lstCM) {
            result.put(getCMKey(iCM), iCM);
        }
        return result;
    }

    private static String getCMKey(Lead lead) {
        return lead.Id + '@' + lead.Campanha__c;
    }

    private static String getCMKey(CampaignMember cm) {
        return cm.LeadId + '@' + cm.CampaignId;
    }
}