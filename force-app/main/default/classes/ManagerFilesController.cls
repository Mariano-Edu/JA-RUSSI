public class ManagerFilesController {
    static final String CAMINHO_PADRAO_PARA_ARQUIVOS_IMAGEM = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=';
    static final String CAMINHO_PADRAO_PARA_ARQUIVOS_PDF = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';

    @AuraEnabled
    public static List<ManagerFilesDTO.File> buscarArquivosPorIdLinkedEntity(Id idLinkedEntity) {
        List<ContentDocumentLink> arquivos = ContentDocumentLinkSelector.obterLinksDocumentosPorLinkedEntityId(idLinkedEntity);
        List<ManagerFilesDTO.File> arquivosRetorno = new List<ManagerFilesDTO.File>();

        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();

        for(ContentDocumentLink arquivo : arquivos) {
            String urlVisualizador = sfdcBaseURL;

            if(arquivo.ContentDocument.FileType.toLowercase() == 'pdf') {
                urlVisualizador += CAMINHO_PADRAO_PARA_ARQUIVOS_PDF + arquivo.ContentDocument.LatestPublishedVersionId;
            } else {
                urlVisualizador += CAMINHO_PADRAO_PARA_ARQUIVOS_IMAGEM + arquivo.ContentDocument.LatestPublishedVersionId;
            }
            
            arquivosRetorno.add(new ManagerFilesDTO.File(arquivo.ContentDocument.Title, arquivo.ContentDocumentId, urlVisualizador, 'native', arquivo.ContentDocumentId, 
            arquivo.ContentDocument.Title, arquivo.ContentDocument.Owner.Name, arquivo.ContentDocument.ContentSize, null, arquivo.ContentDocument.LastModifiedDate));
        }

        return arquivosRetorno;
    }
}