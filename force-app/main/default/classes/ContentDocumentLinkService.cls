public class ContentDocumentLinkService {
    static Set<String> tiposDocumentosUnicos = new Set<String> {
        'Documento__c'
    };

    public static void substituirLinkDocumento(List<ContentDocumentLink> linksDocumentos) {
        for (ContentDocumentLink linkDocumento : linksDocumentos) {
            if (tiposDocumentosUnicos.contains(String.valueOf(linkDocumento.LinkedEntityId.getsobjecttype()))) {
                List<ContentDocumentLink> contentLinks = ContentDocumentLinkSelector.obterLinksDocumentosPorLinkedEntityId(linkDocumento.LinkedEntityId);

                delete contentLinks;
            }
        }
    }

    @AuraEnabled
    public static String carregarArquivo(String base64, String filename, String recordId, String extensao) {
        List<ExtensoesDocumentosChecklist__mdt> extensoesPermitidasMdt = DocumentosChecklistSelector.buscarExtensoesPermitidasDocumentosChecklist();

        List<String> extensoesPermitidas = new List<String>();
        
        for(ExtensoesDocumentosChecklist__mdt extensaoPermitida : extensoesPermitidasMdt) {
            extensoesPermitidas.add(extensaoPermitida.Extensao__c.toLowerCase());
        }

        if(!extensoesPermitidas.contains(extensao)) return 'Erro ao carregar arquivo ' + filename + ': Extensão ' + extensao + ' não permitida.';

        ContentVersion cv = criarVersaoConteudo(base64, filename);
        ContentDocumentLink cdl = criarVinculoDocumento(cv.Id, recordId);

        return (cv == null || cdl == null) ? null : cdl.Id;
    }
  
    private static ContentVersion criarVersaoConteudo(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;

        try {
            insert cv;
            return cv;
        } catch(DMLException erro) {
            System.debug('Erro ao criar versão de documento: ' + erro);

            return null;
        }
    }

    private static ContentDocumentLink criarVinculoDocumento(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) return null;

        ContentDocumentLink cdl = new ContentDocumentLink();

        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        
        cdl.LinkedEntityId = recordId;

        cdl.ShareType = 'V';
        
        try {
          insert cdl;

          return cdl;
        } catch(DMLException erro) {
          System.debug('Erro ao criar vínculo de documento: ' + erro);
          
          return null;
        }
    }
}