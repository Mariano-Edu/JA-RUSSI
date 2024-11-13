public class QuoteHelper {
    public static void handleBeforeInsert(List<Quote> quotes) {
        handleStandardPricebook(quotes);
    }
    
    public static void handleAfterInsert(List<Quote> quotes) {
        handleUpdateName(quotes);
    }

    public static void handleBeforeUpdate(List<Quote> quotes) {
        approveQuotes(quotes);
    }
    
    public static void handleAfterUpdate(List<Quote> quotes, Map<Id,Quote> oldQuotes) {
        List<Quote> quotesToValidate = ObjectHelper.filterObjectsByFieldValue(quotes, 'Status', 'Em Aprovação');
        List<Quote> approvedQuotes = ObjectHelper.filterObjectsByFieldValue(quotes, 'Status', 'Aprovada');
        handleApprovalRequests(quotesToValidate);
        handleApprovedQuotes(approvedQuotes);
    }

    private static void handleStandardPricebook(List<Quote> quotes) {
        for(Quote quote : quotes) {
            if(quote.Pricebook2Id == null) {
                quote.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;
            }
        }
    }

    private static void approveQuotes(List<Quote> quotes) {
        List<Quote> approvedQuotes = new List<Quote>();

        for(Quote iQuote : quotes) {
            if(iQuote.DescontoConformeTabela__c && iQuote.ComissaoConformeTabela__c) {
                approvedQuotes.add(iQuote);
                iQuote.Status = 'Aprovada';
            }
        }
    }

    private static void handleUpdateName(List<Quote> quotes) {
        List<Quote> quotesToUpdate = new List<Quote>();
        
        for(Quote iQuote : quotes) {
            Quote quoteToUpdate = new Quote(
                Id = iQuote.Id,
                Name = iQuote.NomeCotacao__c
            );

            quotesToUpdate.add(quoteToUpdate);
        }
        
        if(!quotesToUpdate.isEmpty()) {
            TriggerHandler.bypass('QuoteTriggerHandler');
            update quotesToUpdate;
            TriggerHandler.clearBypass('QuoteTriggerHandler');
        }
    }

    public static void handleApprovalRequests(List<Quote> quotes) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        List<Quote> approvedQuotes = new List<Quote>();

        for(Quote iQuote : quotes) {
            if(iQuote.DescontoConformeTabela__c && iQuote.ComissaoConformeTabela__c) {
                approvedQuotes.add(iQuote);
                continue;
            }

            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments('Aprovação da cotação de id: ' + iQuote.Id);
            request.setObjectId(iQuote.Id);
            request.setProcessDefinitionNameOrId('AprovacaoCotacao');
            request.setSubmitterId(UserInfo.getUserId());
            request.setSkipEntryCriteria(true);
            approvalRequests.add(request);
        }

        if(!approvalRequests.isEmpty()) {
            Approval.process(approvalRequests);
        }

        if(!approvedQuotes.isEmpty()) {
            sendAutomaticApprovalsEmails(approvedQuotes);
        }
    }

    private static void sendAutomaticApprovalsEmails(List<Quote> quotes) {
        List<User> diretorComercialMailAddress = [SELECT Email FROM User WHERE UserRole.DeveloperName = 'Diretor_Comercial'];

        EmailTemplate template = [
            SELECT
                Id,
                Body,
                Subject
            FROM EmailTemplate  
            WHERE DeveloperName = 'TemplateCotacaoAprovadaAutomaticamente' 
            LIMIT 1
        ];

        String emailDiretorComercial = [SELECT Email FROM User WHERE UserRole.DeveloperName = 'Diretor_Comercial' LIMIT 1].Email;
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for(Quote iQuote : quotes) {
            messages.add(buildQuoteApprovalEmail(iQuote, emailDiretorComercial, template));
        }

        Messaging.sendEmail(messages);
    }

    private static Messaging.SingleEmailMessage buildQuoteApprovalEmail(
        Quote quote,
        String receiver,
        EmailTemplate template
    ) {

        String emailBody = template.Body;

        emailBody = emailBody.replace('{!Quote.NomeProprietarioOportunidade__c}', quote.NomeProprietarioOportunidade__c);
        emailBody = emailBody.replace('{!Quote.LineItemCount}', String.valueOf(quote.LineItemCount));
        emailBody = emailBody.replace('{!Quote.TotalPrice}', String.valueOf(quote.TotalPrice).replace('.', ','));
        emailBody = emailBody.replace('{!Quote.PrecoLista__c}', quote.PrecoLista__c != null ? String.valueOf(quote.PrecoLista__c).replace('.', ',') : '0,00');

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.setPlainTextBody(emailBody);
        message.setSubject(template.Subject);
        message.setWhatId(quote.AccountId);
        message.setToAddresses(new String[]{receiver});
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);

        return message;
    }

    private static void handleApprovedQuotes(List<Quote> quotes) {
        Map<Id,Opportunity> opps = new Map<Id,Opportunity>(
            OpportunityDA.getOpportunitiesById(
                new Set<String>{'Id', 'StageName'},
                ObjectHelper.getLookUpId(quotes, 'OpportunityId')
            )
        );

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for(Quote iQuote : quotes) {
            Opportunity opp = opps.get(iQuote.OpportunityId);

            if(opp.StageName != 'Proposta' || iQuote.Status != 'Aprovada') {
                continue;
            }

            opp.StageName = 'Documentação';
            oppsToUpdate.add(opp);
        }

        if(!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }

        sendAutomaticApprovalsEmails(quotes);
    }
}