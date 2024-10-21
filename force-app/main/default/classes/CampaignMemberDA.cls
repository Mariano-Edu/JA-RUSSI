public class CampaignMemberDA {

    public static List<CampaignMember> getByLeadCampaign(Set<String> fields, Set<Id> setLeadId, Set<Id> setCampaignId){
        return Database.query(String.format(
            'SELECT {0} FROM CampaignMember WHERE LeadId IN :setLeadId AND CampaignId IN :setCampaignId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}