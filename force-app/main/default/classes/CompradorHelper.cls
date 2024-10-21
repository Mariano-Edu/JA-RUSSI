public with sharing class CompradorHelper {
    
    public static void getTotalPercent(List<Comprador__c> compradores) {
        if (compradores == null || compradores.isEmpty()) {
            return;
        }
        
        Set<Id> oportunidadeIds = new Set<Id>();
        for (Comprador__c participante : compradores) {
            if (participante.Oportunidade__c != null) {
                oportunidadeIds.add(participante.Oportunidade__c);
            }
        }
        
        Map<Id, Decimal> opportunityPercentages = new Map<Id, Decimal>();
        Map<Id, Comprador__c> mapExistingTipoParticipante = new Map<Id, Comprador__c>();
        List<Comprador__c> allTipoParticipantes = [
            SELECT Oportunidade__c, PorcentagemDeParticipacao__c
            FROM Comprador__c
            WHERE Oportunidade__c IN :oportunidadeIds
        ];
        
        for (Comprador__c tipoParticipante : allTipoParticipantes) {
            if (tipoParticipante.Oportunidade__c != null) {
                Decimal currentPercentage = tipoParticipante.PorcentagemDeParticipacao__c != null ? tipoParticipante.PorcentagemDeParticipacao__c : 0;
                if (opportunityPercentages.containsKey(tipoParticipante.Oportunidade__c)) {
                    opportunityPercentages.put(tipoParticipante.Oportunidade__c, opportunityPercentages.get(tipoParticipante.Oportunidade__c) + currentPercentage);
                } else {
                    opportunityPercentages.put(tipoParticipante.Oportunidade__c, currentPercentage);
                }
            }
            mapExistingTipoParticipante.put(tipoParticipante.Id, tipoParticipante);
        }
        
        for (Comprador__c participante : compradores) {
            if (participante.Oportunidade__c != null && opportunityPercentages.containsKey(participante.Oportunidade__c)) {
                Decimal total = opportunityPercentages.get(participante.Oportunidade__c);
                
                Decimal currentParticipation = participante.PorcentagemDeParticipacao__c != null ? participante.PorcentagemDeParticipacao__c : 0;
                
                if (mapExistingTipoParticipante.containsKey(participante.Id)) {
                    total -= mapExistingTipoParticipante.get(participante.Id).PorcentagemDeParticipacao__c != null ? mapExistingTipoParticipante.get(participante.Id).PorcentagemDeParticipacao__c : 0;
                }
                
                Decimal newTotal = total + currentParticipation;
                
                if (newTotal > 100) {
                    participante.addError('O Total de participação não pode exceder 100%');
                } else {
                    opportunityPercentages.put(participante.Oportunidade__c, newTotal);
                }
            }
        }
    }
    
    public static void validarCompradorDuplicado(List<Comprador__c> compradores) {
        if (compradores == null || compradores.isEmpty()) {
            return;
        }

        for (Comprador__c comprador : compradores) {
            if ((comprador.Conta__c == null) || (comprador.Oportunidade__c == null)) {
                continue;
            }
            
            List<Comprador__c> duplicados = CompradorSelector.obterCompradorPorIdConta(comprador.Conta__c, comprador.Oportunidade__c);
            
            if (duplicados.isEmpty()) {
                continue;
            }

            for (Comprador__c duplicado : duplicados) {
                if ((duplicado != null) && ObjectHelper.isEqualField(comprador, duplicado, 'Conta__c') && ObjectHelper.isEqualField(comprador, duplicado, 'Oportunidade__c') && !ObjectHelper.isEqualField(comprador, duplicado, 'Id')) {
                    comprador.addError('Já existe um comprador para essa conta.');
                }
            }
        }
    }
    
    public static void validarCompradorPrincipal(List<Comprador__c> compradores) {
        if (compradores == null || compradores.isEmpty()) {
            return;
        }
        
        Set<Id> setIdOportunidades = new Set<Id>();
        for (Comprador__c comprador : compradores) {
            if (comprador.CompradorPrincipal__c != 'Sim') {
                continue;
            }
            
            setIdOportunidades.add(comprador.Oportunidade__c);
        }   
        
        if (!setIdOportunidades.isEmpty()) {

            List<Comprador__c> compradoresExistentes = CompradorSelector.obterCompradoresPrincipaisPorOportunidades(setIdOportunidades);

            Map<Id, Comprador__c> mapCompradoresOportunidade = new Map<Id, Comprador__c>();
            Map<Id, Comprador__c> mapCompradoresId = new Map<Id, Comprador__c>();

            for (Comprador__c compradorExistente : compradoresExistentes) {
                mapCompradoresOportunidade.put(compradorExistente.Oportunidade__c, compradorExistente);
                mapCompradoresId.put(compradorExistente.Id, compradorExistente);
            }

            for (Comprador__c comprador : compradores) {                
                if (comprador.Oportunidade__c != null && mapCompradoresOportunidade.containsKey(comprador.Oportunidade__c) && (mapCompradoresId.get(comprador.Id) == null || !ObjectHelper.isEqualField(comprador, mapCompradoresId.get(comprador.Id), 'CompradorPrincipal__c'))) {
                    comprador.addError('Já possui um comprador principal');
                }
            }
        }
    }
    
    public static void getOpportunityType(List<Comprador__c> compradores) {
        
            if (compradores == null || compradores.isEmpty()) {
                    return;
            }

            Set<Id> setAccountId = new Set<Id>();
            for (Comprador__c comprador : compradores) {
                setAccountId.add(comprador.Conta__c);
            }

            Map<Id, Account> mapAccountId = new Map<Id, Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN :setAccountId]);
        
            for (Comprador__c participante : compradores) {
                String accountType = mapAccountId.get(participante.Conta__c).RecordType.DeveloperName;

                if (accountType == 'PessoaFisicaPF' && participante.TipoParticipante__c == 'Sócio') {
                    participante.addError('Não é permitido definir "Sócio" para oportunidades com Conta Pessoal (PF).');
                }
                
                if (accountType == 'PessoaJuridicaPJ' && participante.TipoParticipante__c == 'Comprador') {
                    participante.addError('Não é permitido definir "Comprador" para oportunidades com Conta Jurídica (PJ).');
                }
            }
    }
    
    public static void getEstadoCivil(List<Comprador__c> compradores) {
        if (compradores == null || compradores.isEmpty()) {
            return;
        }
    
        Set<Id> opportunityIds = new Set<Id>();
        for (Comprador__c participante : compradores) {
            if (participante.Oportunidade__c != null) {
                opportunityIds.add(participante.Oportunidade__c);
            }
        }
    
        Map<Id, Integer> conjugeCountMap = new Map<Id, Integer>();
        Map<Id, Comprador__c> mapExistingTipoParticipante = new Map<Id, Comprador__c>();
        List<Comprador__c> existingTipoParticipantes = [
            SELECT Id, Oportunidade__c, TipoParticipante__c 
            FROM Comprador__c 
            WHERE Oportunidade__c IN :opportunityIds
        ];
    
        for (Comprador__c existingTipoParticipante : existingTipoParticipantes) {
            if (existingTipoParticipante.TipoParticipante__c == 'Cônjuge/Companheiro') {
                if (!conjugeCountMap.containsKey(existingTipoParticipante.Oportunidade__c)) {
                    conjugeCountMap.put(existingTipoParticipante.Oportunidade__c, 0);
                }
                conjugeCountMap.put(existingTipoParticipante.Oportunidade__c, conjugeCountMap.get(existingTipoParticipante.Oportunidade__c) + 1);
            }
            mapExistingTipoParticipante.put(existingTipoParticipante.Id, existingTipoParticipante);
        }
    
        for (Comprador__c participante : compradores) {

            if(participante.CompradorPrincipal__c == 'Sim' && participante.PorcentagemDeParticipacao__c == null ){
                participante.PorcentagemDeParticipacao__c = 50;
            }

            if (participante.TipoParticipante__c == 'Cônjuge/Companheiro') {
                Integer totalConjuges = conjugeCountMap.get(participante.Oportunidade__c) != null ? conjugeCountMap.get(participante.Oportunidade__c) : 0;
    
                totalConjuges++;
    
                if (totalConjuges > 1) {
                    if (mapExistingTipoParticipante.containsKey(participante.Id) && mapExistingTipoParticipante.get(participante.Id).TipoParticipante__c == participante.TipoParticipante__c) {
                        continue;
                    }
                    participante.addError('O papel "' + participante.TipoParticipante__c + '" só pode ser associado uma vez por oportunidade.');
                } else {
                    conjugeCountMap.put(participante.Oportunidade__c, totalConjuges);
                    if (participante.PorcentagemDeParticipacao__c == null) {
                        participante.PorcentagemDeParticipacao__c = 50;
                    }
                }
            }
        }
    }

    
    
}