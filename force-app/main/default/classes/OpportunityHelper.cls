public with sharing class OpportunityHelper {
    
    public static void handleNewOpportunities(List<Opportunity> opportunities, Map<Id,Opportunity> oldOpportunitiesMap) {
        validateDuplicates(opportunities, oldOpportunitiesMap);
    }

    public static void handleBeforeUpdate(List<Opportunity> opportunities, Map<Id,Opportunity> oldOpportunitiesMap) {
        validateDuplicates(opportunities, oldOpportunitiesMap);
    }

    private static void validateDuplicates(List<Opportunity> opportunities, Map<Id,Opportunity> oldOpportunitiesMap) {
        for (Opportunity iOpp : opportunities) {

            if (iOpp.Unidade__c == null || iOpp.ResponsavelPeloLead__c == null) {
                continue;
            }

            List<Opportunity> duplicatedOpps = OpportunityDA.getOpportunityByAccountProduct(iOpp.AccountId, iOpp.Unidade__c, iOpp.ResponsavelPeloLead__c, iOpp.Corretor__c);

            Set<String> stageNameSet = ObjectHelper.getFieldValuesFromList([SELECT MasterLabel FROM OpportunityStage WHERE IsClosed = true], 'MasterLabel');
            Set<String> stageValueSet = ObjectHelper.getFieldValuesFromList(duplicatedOpps, 'StageName');
            
            for (Opportunity duplicada : duplicatedOpps) {
                
                if (duplicatedOpps.isEmpty() || ObjectHelper.containsAny(stageValueSet, stageNameSet) || ObjectHelper.isEqualField(new Set<String>{'AccountId', 'Unidade__c', 'ResponsavelPeloLead__c', 'Corretor__c'}, opportunities, oldOpportunitiesMap) || ObjectHelper.isEqualField(iOpp, duplicada, 'Id')) {
                    continue;
                }
                
                iOpp.addError('Não é possível criar uma oportunidade duplicada.');
            }
        }
    }   

    public static void validateDoc(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        if (newOpps == null || oldOpps == null) {
            return;
        }
    
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            opportunityIds.add(opp.Id);
        }
    
        Map<Id, List<Documento__c>> documentosPorOportunidade = new Map<Id, List<Documento__c>>();
    
        List<Documento__c> documentosEntregues = [
            SELECT Id, StatusAprovacao__c, Oportunidade__c 
            FROM Documento__c 
            WHERE Oportunidade__c IN :opportunityIds 
            AND Entregue__c = TRUE
        ];
    
    
        for (Documento__c doc : documentosEntregues) {
            if (!documentosPorOportunidade.containsKey(doc.Oportunidade__c)) {
                documentosPorOportunidade.put(doc.Oportunidade__c, new List<Documento__c>());
            }
            documentosPorOportunidade.get(doc.Oportunidade__c).add(doc);
        }
    
        for (Opportunity opp : newOpps) {
            Opportunity oldOpp = oldOpps.get(opp.Id);
            List<Documento__c> docsRelacionados = documentosPorOportunidade.get(opp.Id);
    
    
            if (oldOpp.StageName == 'Análise Jurídica' && opp.StageName == 'Aprovação') {
                if (docsRelacionados != null && !docsRelacionados.isEmpty()) {
                    Boolean todosAprovados = true;
                    Boolean algumEntregueNaoAprovado = false;
    
                    for (Documento__c doc : docsRelacionados) {
                        if (doc.StatusAprovacao__c != 'Aprovado') {
                            todosAprovados = false;
    
                            if (doc.StatusAprovacao__c == 'Entregue') {
                                algumEntregueNaoAprovado = true;
                            }
                        }
                    }
    
                    if (algumEntregueNaoAprovado) {
                        opp.addError('A oportunidade não pode avançar para a fase de aprovação porque existem documentos entregues que não estão aprovados.');
                    } else if (!todosAprovados) {
                        opp.addError('A oportunidade só pode avançar para a fase de aprovação quando todos os documentos entregues estiverem com o status "Aprovado".');
                    }
                }
            }
        }
    }
    
    public static void createAnaliseCredito(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        List<AnaliseDeCredito__c> novasAnalises = new List<AnaliseDeCredito__c>();

        for (Opportunity opp : newOpps) {
            Opportunity oldOpp = oldOpps.get(opp.Id);
            
            if (oldOpp.StageName != 'Documentação' && opp.StageName == 'Documentação') {
                AnaliseDeCredito__c novaAnalise = new AnaliseDeCredito__c();
                novaAnalise.Oportunidade__c = opp.Id;
                novasAnalises.add(novaAnalise);
            }
        }
    
        if (!novasAnalises.isEmpty()) {
            insert novasAnalises;
        }
    }
    
    
}