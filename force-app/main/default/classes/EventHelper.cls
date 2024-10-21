public with sharing class EventHelper {

    public static void validateEventLookup(List<Event> events) {

        Set<Id> opportunityIds = new Set<Id>();
        for (Event iEvent : events) {
            if (iEvent.WhatId != null && iEvent.WhatId.getSObjectType() == Opportunity.SObjectType) {
                opportunityIds.add(iEvent.WhatId);
            }
        }

        Map<Id, Opportunity> opportunitiesMap = EventDA.getOpportunitiesByEventIds(opportunityIds);


        Set<Id> eventIds = new Set<Id>();
        for (Event iEvent : events) {
            if (iEvent.Id != null) {
                eventIds.add(iEvent.Id);
            }
        }
        Map<Id, Event> existingEventsMap = new Map<Id, Event>([SELECT Id, EndDateTime FROM Event WHERE Id IN :eventIds]);
    

        for (Event iEvent : events) {

            if (iEvent.StatusVisita__c == 'Cancelado' && iEvent.MotivoCompromissoNaoRealizado__c == null) {
                iEvent.addError('Preencha o Motivo do Compromisso Cancelado');

                
            }
            
            if (existingEventsMap.containsKey(iEvent.Id)) {
                Event existingEvent = existingEventsMap.get(iEvent.Id);
                if (existingEvent.EndDateTime > DateTime.now()) {
                    iEvent.StatusVisita__c = 'NotDone';
                    iEvent.MotivoCompromissoNaoRealizado__c = 'Outros';
                }
            }

            if (iEvent.WhatId != null && iEvent.WhatId.getSObjectType() == Opportunity.SObjectType) {
                Opportunity opp = opportunitiesMap.get(iEvent.WhatId);

                if (opp != null && opp.StageName == 'Fechado e Perdido') {
                    iEvent.addError('Não é permitido criar eventos para oportunidades no estágio "Fechado e perdido".');
                } else{
                    sendEmailToClient(iEvent, opp);

                }
            }
        }

        Map<Id,Lead> leadMap = new Map<Id,Lead>(
            LeadDA.getLeadsById(
                new Set<String>{'EmpreendimentoInteresse__c'},
                ObjectHelper.getLookUpId(events, 'WhoId')
            )
        );
        
        for(Event iEvent : events) {
            if(!leadMap.containsKey(iEvent.WhoId)) continue;

            Lead leadRecord = leadMap.get(iEvent.WhoId);
            
            if(String.isBlank(iEvent.Subject)) iEvent.Subject = iEvent.Type;

            if(!String.isBlank(leadRecord.EmpreendimentoInteresse__c)) {
                iEvent.EmpreendimentoInteresse__c = leadRecord.EmpreendimentoInteresse__c;
            }
        
        }
    }

    private static void sendEmailToClient(Event iEvent, Opportunity opp) {
        try {
            String clientEmail = null;
            String clientName = null;
            String atendente = UserInfo.getName();
            String empreendimento = null;
    
            List<Opportunity> oppWithAccountList = [SELECT Id, Name, AccountId, EmpreendimentodeInteresse__r.Name 
                                                    FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
    
            if (!oppWithAccountList.isEmpty()) {
                Opportunity oppWithAccount = oppWithAccountList[0];
                clientName = oppWithAccount.Name;
                empreendimento = oppWithAccount.EmpreendimentodeInteresse__r.Name;
    
                if (oppWithAccount.AccountId != null) {
                    List<Account> accountList = [SELECT Id, IsPersonAccount, PersonEmail, EmailPJ__c
                                                 FROM Account WHERE Id = :oppWithAccount.AccountId LIMIT 1];
    
                    if (!accountList.isEmpty()) {
                        Account account = accountList[0];
    
                        if (account.IsPersonAccount) {
                            clientEmail = account.PersonEmail;
                        } else {
                            clientEmail = account.EmailPJ__c;
                        }
                    }
                }
            }
    
            if (String.isBlank(clientEmail)) {
                return;
            }
    
            String emailBody = '';
            String subject = '';
            String eventType = '';
            
            if (iEvent.Subject.contains('Visita')) {
                eventType = 'Visita';
            } else if (iEvent.Subject.contains('Reunião online')) {
                eventType = 'Reunião online';
            } else if (iEvent.Subject.contains('Reunião Presencial')) {
                eventType = 'Reunião Presencial';
            }
    
            switch on eventType {
                when 'Visita' {
                    subject = 'Informações da Visita';
                    emailBody = 'Olá ' + clientName + '!\n' +
                                'Conforme combinado, sua visita ao empreendimento ' + empreendimento + ' ficou agendada para o dia ' + iEvent.StartDateTime.format('dd/MM/yyyy') + ', às ' + iEvent.StartDateTime.format('HH:mm') + 'hs.\n\n' +
                                'Qualquer dúvida, estamos à disposição. Até breve!\n\n' +
                                'Att\n' +
                                atendente;
                }
                when 'Reunião online' {
                    subject = 'Informações da Reunião On-Line';
                    emailBody = 'Olá ' + clientName + '!\n' +
                                'Conforme combinado, nossa reunião on-line referente ao empreendimento ' + empreendimento + ' ficou agendada para o dia ' + iEvent.StartDateTime.format('dd/MM/yyyy') + ', às ' + iEvent.StartDateTime.format('HH:mm') + 'hs.\n\n' +
                                'No dia de nossa reunião enviaremos o link.\n' +
                                'Qualquer dúvida, estamos à disposição. Até breve!\n\n' +
                                'Att\n' +
                                atendente;
                }
                when 'Reunião Presencial' {
                    if (String.isBlank(iEvent.Location)) {
                        iEvent.addError('O local é obrigatório para reuniões presenciais.');
                    }
                    subject = 'Informações da Reunião Presencial';
                    emailBody = 'Olá ' + clientName + '!\n' +
                                'Conforme combinado, nossa reunião presencial referente ao empreendimento ' + empreendimento + ' ficou agendada para o dia ' + iEvent.StartDateTime.format('dd/MM/yyyy') + ', às ' + iEvent.StartDateTime.format('HH:mm') + 'hs.\n\n' +
                                'Local agendado: ' + iEvent.Location + '\n' +
                                'Qualquer dúvida, estamos à disposição. Até breve!\n\n' +
                                'Att\n' +
                                atendente;
                }
            }
    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{clientEmail});
            mail.setSubject(subject);
            mail.setPlainTextBody(emailBody);
            mail.setReplyTo(UserInfo.getUserEmail());
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}