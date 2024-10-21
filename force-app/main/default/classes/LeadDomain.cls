public class LeadDomain {
    public static Lead obterLeadPorId(Id idLead) {
        List<Lead> leads = LeadSelector.obterLeadsPorIds(new Set<Id>{ idLead });

        return leads.isEmpty() ? new Lead() : leads.get(0);
    }

    public static Map<String, List<Lead>> obterLeadsPorCanalAtendimento(List<Lead> leads) {
        Map<String, List<Lead>> leadsPorCanalAtendimento = new Map<String, List<Lead>>();
        for(Lead lead : leads) {
            if(!leadsPorCanalAtendimento.containsKey(lead.CanalAtendimento__c)) {
                leadsPorCanalAtendimento.put(lead.CanalAtendimento__c, new List<Lead>());
            }

            leadsPorCanalAtendimento.get(lead.CanalAtendimento__c).add(lead);
        }

        return leadsPorCanalAtendimento;
    }
}