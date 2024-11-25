public with sharing class GeracaoMinutaService {
    
    @AuraEnabled
    public static Id gerarMinutaByContract(String contractId){


        Opportunity opp = OpportunityDA.getOpportunitiesByContractId(contractId);

        if(opp <> null && opp.EmpreendimentodeInteresse__c <> null){

            Minuta__c minuta =  MinutaSelector.getMinutaFromEmpreendimentoId(opp.EmpreendimentodeInteresse__c);
            
            
            PageReference pageRef = Page.GeracaoMinuta;
            pageRef.getParameters().put('minutaId', minuta.Id);
            pageRef.getParameters().put('fileRefId', contractId);
            pageRef.getParameters().put('obj_refs', JSON.serialize(new List<String>{opp.EmpreendimentodeInteresse__c,opp.Unidade__c}));
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Documento Gerado - ' + Datetime.now().format();
            contentVersion.PathOnClient = 'testeMinuta.pdf';
            contentVersion.VersionData =    Test.isRunningTest() ? Blob.valueOf('test') : pageRef.getContent();
            contentVersion.ContentLocation = 'S';
            contentVersion.IsMajorVersion = true;
            insert contentVersion;
            
            System.debug( contentVersion.Id);
            
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = :contentVersion.Id LIMIT 1];
            System.debug( cv.ContentDocumentId);
            
            createFileRef( cv.ContentDocumentId, contractId);
            
            return cv.ContentDocumentId;
        }

        return '';
    }

    @AuraEnabled
    public static Id gerarMinutaExample(String minutaId){
            
            PageReference pageRef = Page.GeracaoMinuta;
            pageRef.getParameters().put('minutaId', minutaId);
            pageRef.getParameters().put('fileRefId', minutaId);
            pageRef.getParameters().put('obj_refs', JSON.serialize(new List<String>()));

            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = 'Documento Gerado - ' + Datetime.now().format();
            contentVersion.PathOnClient = 'testeMinuta.pdf';
            contentVersion.VersionData =    Test.isRunningTest() ? Blob.valueOf('test') : pageRef.getContent();
            contentVersion.ContentLocation = 'S';
            contentVersion.IsMajorVersion = true;
            insert contentVersion;
            
            System.debug( contentVersion.Id);
            
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = :contentVersion.Id LIMIT 1];
            System.debug( cv.ContentDocumentId);
            
            createFileRef( cv.ContentDocumentId, minutaId);
            
            return cv.ContentDocumentId;

    }

    public static void createFileRef(Id contentDocumentId, Id entityId){
        if(String.isNotBlank(entityId)){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.linkedEntityId = entityId;
            cdl.ContentDocumentId = contentDocumentId;
            insert cdl;
        }
    }

    public static String gerarConteudo(String minutaId, Id fileRefId){
        Minuta__c minuta = MinutaSelector.getMinutasFromId(minutaId).get(minutaId);
        Map<String, Clausulas__c> mapAllClausulas = ClausulasSelector.getAllClausulasBySetCode();
        String conteudoMinuta = '';
        
        if(minuta <> null) {
            conteudoMinuta = minuta.Corpo__c;
            for (String clausula_code : mapAllClausulas.keySet()) {
                if(conteudoMinuta.containsIgnoreCase(clausula_code)){
                    conteudoMinuta = conteudoMinuta.replaceAll(clausula_code, mapAllClausulas.get(clausula_code).Conteudo__c);
                }         
            }
        }

        String sObjName = fileRefId.getSObjectType().getDescribe().getName();

        if(sObjName.equalsIgnoreCase('Contract') || sObjName.equalsIgnoreCase('Contrato')){
            List<Signatario__c> signers = [Select Id, Contrato__c,Name,TipoSignatario__c from Signatario__c where Contrato__c =: fileRefId];
            conteudoMinuta = replaceSignTags(signers, conteudoMinuta);
        }

        return conteudoMinuta;
    }

    public static String gerarConteudo(String minutaId, Id fileRefId, List<Id> objectsToReplace){
        Minuta__c minuta = MinutaSelector.getMinutasFromId(minutaId).get(minutaId);
        Map<String, Clausulas__c> mapAllClausulas = ClausulasSelector.getAllClausulasBySetCode();
        String conteudoMinuta = '';
        
        if(minuta <> null) {
            conteudoMinuta = minuta.Corpo__c;
            for (String clausula_code : mapAllClausulas.keySet()) {
                if(conteudoMinuta.containsIgnoreCase(clausula_code)){
                    conteudoMinuta = conteudoMinuta.replaceAll(clausula_code, mapAllClausulas.get(clausula_code).Conteudo__c);
                }         
            }
        }

        String sObjName = fileRefId.getSObjectType().getDescribe().getName();

        if(sObjName.equalsIgnoreCase('Contract') || sObjName.equalsIgnoreCase('Contrato')){
            List<Signatario__c> signers = [Select Id, Contrato__c,Name,TipoSignatario__c from Signatario__c where Contrato__c =: fileRefId];
            conteudoMinuta = replaceSignTags(signers, conteudoMinuta);
        }

        if(!objectsToReplace.isEmpty()){
            for (Id objectId : objectsToReplace) {
                conteudoMinuta = replaceObjectFieldTags(objectId, conteudoMinuta);
            }
        }

        return conteudoMinuta;
    }

    public static String replaceObjectFieldTags(Id objectId, String conteudo){
        String sObjName = objectId.getSObjectType().getDescribe().getName();

        Map<String,String> mapFieldTag =  new Map<String,String>();

        for(Parametro_Geral__c param : [Select Id, ObjetoReferencia__c,CampoSubstituido__c,TagCampo__c
                                        FROM Parametro_Geral__c
                                        where Ativo__c = true
                                        AND ObjetoReferencia__c =: sObjName]){
            mapFieldTag.put(param.TagCampo__c, param.CampoSubstituido__c);
        }

        List<String> fieldsToQuery = new List<String>(mapFieldTag.values());
        
        if(fieldsToQuery.isEmpty()) return conteudo;
        

        SObject obj_ref = Database.query(String.format(
            'SELECT {0} FROM '+ sObjName +' WHERE Id =: objectId',
            new String[]{String.join(fieldsToQuery, ',')}
        ));

        if(obj_ref <> null) {
            for(String field_tag : mapFieldTag.keySet()){
                conteudo = conteudo.replaceAll(field_tag, String.valueOf(obj_ref.get(mapFieldTag.get(field_tag))));
            }
        }

        return conteudo;
    }

    public static String replaceSignTags(List<Signatario__c> signatarios, String conteudo){
        Map<String,Parametro_Geral__c> mapParameter =  new Map<String,Parametro_Geral__c>();

        for(Parametro_Geral__c param : [Select Id, TagAssinatura__c,TagDataAssinatura__c,TagNomeCompleto__c,TagRubrica__c,Ativo__c,TipoAssinante__c,TipoDeSignatario__c
                                        FROM Parametro_Geral__c
                                        where Ativo__c = true]){
            mapParameter.put(param.TipoAssinante__c, param);
        }

        if(!signatarios.isEmpty() && !mapParameter.isEmpty()){
            for (Signatario__c signer : signatarios) {
                Parametro_Geral__c  tagsSigner = mapParameter.get(signer.TipoSignatario__c);
                if(tagsSigner <> null){
                    system.debug(JSON.serializePretty(signer));
                    system.debug(JSON.serializePretty(tagsSigner));
                    conteudo = conteudo.replaceAll(tagsSigner.TagNomeCompleto__c, signer.Name);
                    system.debug(conteudo);
                }

            }
        }
        return conteudo;
    }
}