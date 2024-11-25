public with sharing class SendDocusignEnvelopeService {
    private static final String MANAGER_NOT_FOUND = 'Gerente não cadastrado na hierarquia de cargos para essa imobiliária';
    private static final Map<String, List<Parametro_Geral__c>> PARAMETERS;
    private static Map<String, Object> responseMap = new Map<String, Object>();
    private static DocuSignObjects.Envelope envelope = new DocusignObjects.Envelope();
    private static List<DocuSignObjects.Signer> signers = new List<DocuSignObjects.Signer>();
    private static List<DocuSignObjects.Signer> carbonCopies = new List<DocuSignObjects.Signer>();
    private static Integer recipientId;
    private static Integer documentId;

    static {
        PARAMETERS = ParametrosGeraisUtility.getMapDynamic(
            ParametrosGeraisUtility.FIELD_SET, 
            new Set<String>{'RecordType.DeveloperName IN (\'ParametrizacaoWorkflowEnvelopeDocusing\',\'ParametrizacaoAssinaturasDigitaisETAGs\',\'OpcoesAvancadasEnvelopeDocusign\')'},
            // new Set<String>{'RecordType.DeveloperName IN (\'ParametrizacaoWorkflowEnvelopeDocusing\',\'ParametrizacaoAssinaturasDigitaisETAGs\')'},
            'RecordTypeId'
        );
    }

    public static void sendEnvelope(Id contractId){
        Opportunity opp = OpportunityDA.getOpportunitiesByContractId(contractId);
        List<Signatario__c> signers = [Select Id, Contrato__c,Name,TipoSignatario__c from Signatario__c where Contrato__c =: contractId];
        Map<String, Id> signerEmail = new Map<String, Id>();

        for(Signatario__c signer : signers){
            signerEmail.put(signer.Email__c, signer.Id);
        }

        List<EnvelopeDaOportunidade__c> docusignEnvelopes = new List<EnvelopeDaOportunidade__c>();
        List<Signatario__c> docusignSigners = new List<Signatario__c>();

        Map<String, Parametro_Geral__c> signerTagMap = new Map<String, Parametro_Geral__c>();

        for (Parametro_Geral__c tag : PARAMETERS.get('ParametrizacaoAssinaturasDigitaisETAGs')) {
            signerTagMap.put(tag.GrupoFuncao__c, tag);
        }

        getEnvelopeRecipients(signerTagMap, signers);

        List<ContentDocumentLink> contentLink = getDocumentLinks(contractId);
        List<DocuSignObjects.Document> documents = new List<DocuSignObjects.Document>();
        for (ContentDocumentLink link : contentLink) {
            DocuSignObjects.Document document = new DocuSignObjects.Document(link, documentId);
            documents.add(document);
            documentId++;
        }

        String emailSubject = getEnvelopeName(opp);
        envelope.status = 'sent';
        envelope.emailSubject = emailSubject.length() > 100 ? emailSubject.substring(0, 100).toUpperCase() : emailSubject.toUpperCase();
        envelope.documents = documents;

        HttpResponse response = DocuSignService.instance().criarEnvelope(envelope);
        system.debug(response.getBody());

        if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
            system.debug(response.getStatusCode());
        } else {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            EnvelopeDaOportunidade__c envelopeObj = buildEnvelope(opp);
            docusignEnvelopes.add(envelopeObj);
            docusignSigners.addAll(buildSigners(signerEmail));
            //opp.EnvioDocumentosAssinaturaDocusign__c = 'Integrado';
        }

        update docusignEnvelopes;
        update docusignSigners;

    }


    private static void getEnvelopeRecipients(Map<String, Parametro_Geral__c> signerTagMap, List<Signatario__c> signatarios) {
        recipientId = 1;
        documentId = 1;
        
        for (Parametro_Geral__c workflow : PARAMETERS.get('ParametrizacaoWorkflowEnvelopeDocusing')) {
            DocuSignObjects.Signer signer = new DocuSignObjects.Signer(); 
            
            if (workflow.GrupoFuncao__c == 'Proponente') {
                Integer buyerOrder = 1;
                for (Signatario__c buyer : signatarios) {
                    signer = new DocuSignObjects.Signer();
                    if (signerTagMap.containsKey(workflow.GrupoFuncao__c)) {
                        Parametro_Geral__c tagOptions = signerTagMap.get(workflow.GrupoFuncao__c);
                        if (tagOptions != null) {
                            DocusignObjects.Tab tab = new DocusignObjects.Tab();
                            DocuSignObjects.InitialHereTab initialTab = new DocuSignObjects.InitialHereTab();
                            initialTab.recipientId = recipientId;
                            initialTab.anchorString = '<<' + tagOptions.TagRubrica__c.subStringBetween('<<', '>>') + buyerOrder + '>>';
                            initialTab.anchorIgnoreIfNotPresent = 'false';
                            initialTab.anchorXOffset = 1;
                            initialTab.anchorYOffset = 0;
                            initialTab.anchorUnits = 'inches';
                            tab.initialHereTabs.add(initialTab);
                    
                            DocuSignObjects.SignHereTab signHereTab = new DocuSignObjects.SignHereTab();
                            signHereTab.recipientId = recipientId;
                            signHereTab.anchorString = '<<' + tagOptions.TagAssinatura__c.subStringBetween('<<', '>>') + buyerOrder + '>>';
                            signHereTab.anchorXOffset = 1;
                            signHereTab.anchorYOffset = 0;
                            signHereTab.anchorUnits = 'inches';
                            tab.signHereTabs.add(signHereTab);

                            // DocuSignObjects.SignHereTab signHereTab2 = new DocuSignObjects.SignHereTab();
                            // signHereTab2.recipientId = recipientId;
                            // signHereTab2.anchorString = buyerOrder + tagOptions.TagAssinaturaAlternativa__c;
                            // signHereTab2.anchorXOffset = 1;
                            // signHereTab2.anchorYOffset = 0;
                            // signHereTab2.anchorUnits = 'inches';
                            // tab.signHereTabs.add(signHereTab2);
    
                            DocuSignObjects.TextTab signerTextTab = new DocuSignObjects.TextTab();
                            signerTextTab.recipientId = recipientId;
                            signerTextTab.anchorString = '<<' + tagOptions.TagNomeCompleto__c.subStringBetween('<<', '>>') + buyerOrder + '>>';
                            signerTextTab.value = buyer.Name;
                            signerTextTab.tabLabel = 'Nome Completo';
                            signerTextTab.anchorXOffset = 1;
                            signerTextTab.anchorYOffset = 0;
                            signerTextTab.anchorUnits = 'inches';
                            tab.textTabs.add(signerTextTab);
    
                            DocuSignObjects.DateSignedTab dateSignedTab = new DocuSignObjects.DateSignedTab();
                            dateSignedTab.recipientId = recipientId;
                            dateSignedTab.anchorString = '<<' + tagOptions.TagDataAssinatura__c.subStringBetween('<<', '>>') + buyerOrder + '>>';
                            dateSignedTab.anchorXOffset = 1;
                            dateSignedTab.anchorYOffset = 0;
                            dateSignedTab.anchorUnits = 'inches';
                            tab.dateSignedTabs.add(dateSignedTab);
    
                            signer.tabs = tab;
                        }

                        signer.name = buyer.Name;
                        signer.recipientId = String.valueOf(recipientId);
                        signer.email = buyer.Email__c;
                        signer.customFields = new List<String>{workflow.GrupoFuncao__c};
                        signer.routingOrder = String.valueOf(workflow.OrdemDeAssinaturaDoGrupoFuncao__c);

                        DocuSignObjects.RecipientEmailNotification emailNotification = new DocuSignObjects.RecipientEmailNotification();
                        // emailNotification.emailSubject = String.valueOf(workflow.GrupoFuncao__c);
                        emailNotification.emailBody = String.valueOf(workflow.MensagemDeEmail__c);
                        signer.emailNotification = emailNotification;
                        
						system.debug('current proponente signer:');
                    	system.debug(signer);
                        
                        recipientId++;
                        buyerOrder++;
                        if (workflow.TipoDeSignatario__c == 'Assinatura necessária') {
                            signers.add(signer);
                            continue;
                        }
                        carbonCopies.add(signer);
                        continue;
                    }
                }
            }

            // if (workflow.GrupoFuncao__c == 'Fiador' && !opp.Fiadores__r.isEmpty()) {
            //     Integer fiadorOrder = 1;
            //     for (Fiador__c fiador : opp.Fiadores__r) {
            //         signer = new DocuSignObjects.Signer();
            //         if (signerTagMap.containsKey(workflow.GrupoFuncao__c)) {
            //             Parametro_Geral__c tagOptions = signerTagMap.get(workflow.GrupoFuncao__c);
            //             if (tagOptions != null) {
            //                 DocusignObjects.Tab tab = new DocusignObjects.Tab();
            //                 DocuSignObjects.InitialHereTab initialTab = new DocuSignObjects.InitialHereTab();
            //                 initialTab.recipientId = recipientId;
            //                 initialTab.anchorString = '<<' + tagOptions.TagRubrica__c.subStringBetween('<<', '>>') + fiadorOrder + '>>';                            initialTab.anchorIgnoreIfNotPresent = 'false';
            //                 initialTab.anchorIgnoreIfNotPresent = 'false';
            //                 initialTab.anchorXOffset = 1;
            //                 initialTab.anchorYOffset = 0;
            //                 initialTab.anchorUnits = 'inches';
            //                 tab.initialHereTabs.add(initialTab);
                    
            //                 DocuSignObjects.SignHereTab signHereTab = new DocuSignObjects.SignHereTab();
            //                 signHereTab.recipientId = recipientId;
            //                 signHereTab.anchorString = '<<' + tagOptions.TagAssinatura__c.subStringBetween('<<', '>>') + fiadorOrder + '>>';
            //                 signHereTab.anchorXOffset = 1;
            //                 signHereTab.anchorYOffset = 0;
            //                 signHereTab.anchorUnits = 'inches';
            //                 tab.signHereTabs.add(signHereTab);
    
            //                 DocuSignObjects.TextTab signerTextTab = new DocuSignObjects.TextTab();
            //                 signerTextTab.recipientId = recipientId;
            //                 signerTextTab.anchorString = '<<' + tagOptions.TagNomeCompleto__c.subStringBetween('<<', '>>') + fiadorOrder + '>>';
            //                 signerTextTab.value = fiador.Conta__r.Name;
            //                 signerTextTab.tabLabel = 'Nome Completo';
            //                 signerTextTab.anchorXOffset = 1;
            //                 signerTextTab.anchorYOffset = 0;
            //                 signerTextTab.anchorUnits = 'inches';
            //                 tab.textTabs.add(signerTextTab);
    
            //                 DocuSignObjects.DateSignedTab dateSignedTab = new DocuSignObjects.DateSignedTab();
            //                 dateSignedTab.recipientId = recipientId;
            //                 dateSignedTab.anchorString = '<<' + tagOptions.TagDataAssinatura__c.subStringBetween('<<', '>>') + fiadorOrder + '>>';
            //                 dateSignedTab.anchorXOffset = 1;
            //                 dateSignedTab.anchorYOffset = 0;
            //                 dateSignedTab.anchorUnits = 'inches';
            //                 tab.dateSignedTabs.add(dateSignedTab);
    
            //                 signer.tabs = tab;
            //             }                       
            //             signer.name = fiador.Conta__r.Name;
            //             signer.email = fiador.Conta__r.PersonEmail;
            //             signer.recipientId = String.valueOf(recipientId);
            //             signer.customFields = new List<String>{workflow.GrupoFuncao__c};
            //             signer.routingOrder = String.valueOf(workflow.OrdemDeAssinaturaDoGrupoFuncao__c);

            //             DocuSignObjects.RecipientEmailNotification emailNotification = new DocuSignObjects.RecipientEmailNotification();
            //             // emailNotification.emailSubject = String.valueOf(workflow.GrupoFuncao__c);
            //             emailNotification.emailBody = String.valueOf(workflow.MensagemDeEmail__c);
            //             signer.emailNotification = emailNotification;

            //             recipientId++;
            //             fiadorOrder++;

            //             if (workflow.TipoDeSignatario__c == 'Assinatura necessária') {
            //                 signers.add(signer);
            //                 continue;
            //             }
            //             carbonCopies.add(signer);
            //             continue;
            //         }
            //     }
            // }
        }

        envelope.recipients.signers = signers;
        envelope.recipients.carbonCopies = carbonCopies;
    }

    private static EnvelopeDaOportunidade__c buildEnvelope(Opportunity opp) {
        return new EnvelopeDaOportunidade__c(
            Id = opp.EnvelopesDaOportunidade__r.get(0).Id,
            IdDoEnvelope__c = (String) responseMap.get('envelopeId'),
            Status__c = (String) responseMap.get('status')
        );
        
    }

    private static List<Signatario__c> buildSigners(Map<String,Id> mapEmailSignatario) {
        List<Signatario__c> envelopeSigner = new List<Signatario__c>();
        for (DocuSignObjects.Signer signer : signers) {
            Signatario__c signerObj = new Signatario__c(Id = mapEmailSignatario.get(signer.email));
            signerObj.EnvelopeDaOportunidade__r = new EnvelopeDaOportunidade__c(IdDoEnvelope__c = (String) responseMap.get('envelopeId'));
            signerObj.Name = signer.name;
            signerObj.Email__c = signer.email;
            signerObj.OrdemAssinatura__c = Decimal.valueOf(signer.recipientId);
            signerObj.IdSignatario__c = signer.recipientId + ((String) responseMap.get('envelopeId'));
            signerObj.StatusAssinatura__c = 'sent';
            signerObj.DataAssinatura__c = System.now();
            envelopeSigner.add(signerObj);
        }
        return envelopeSigner;
    }

    public static List<ContentDocumentLink> getDocumentLinks(Id contractId) {
        return [
            SELECT ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.VersionData, 
                ContentDocument.LatestPublishedVersion.FileExtension, ContentDocument.LatestPublishedVersion.Title, 
                ContentDocument.LatestPublishedVersion.ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId =: contractId
            ORDER BY ContentDocument.CreatedDate DESC
        ];
    }

    public static String getEnvelopeName(Opportunity opp) {
        return (opp.EmpreendimentodeInteresse__c == null ? '' : (opp.EmpreendimentodeInteresse__r.Name + ' - ')) +
            (opp.Unidade__r.Name == null ? '' : (opp.Unidade__r.Name + ' - ')) +
            opp.Account.Name;
    }
}