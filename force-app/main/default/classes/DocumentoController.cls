public class DocumentoController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Documento__c>> documentosPorCompradorEmOportunidade(Id idOportunidade) {
        Map<String, List<Documento__c>> documentosPorCompradorEmOportunidade = new Map<String, List<Documento__c>>();
        
        List<Comprador__c> compradores = CompradorSelector.obterCompradoresPorOportunidade(idOportunidade);

        for(Comprador__c comprador : compradores) {
            documentosPorCompradorEmOportunidade.put(comprador.Conta__r.Name, DocumentoSelector.obterDocumentosPorComprador(comprador.Id));
        }

        return documentosPorCompradorEmOportunidade;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Documento__c>> documentosPorAnaliseCredito(Id idAnaliseCredito){
        AnaliseDeCredito__c analiseDeCredito = AnaliseCreditoSelector.obterAnaliseCreditoPorId(idAnaliseCredito);
        Map<String, List<Documento__c>> documentos = documentosPorCompradorEmOportunidade(analiseDeCredito.Oportunidade__c);

        return documentos;
    }

    @AuraEnabled
    public static void atualizarStatusDocumento(Map<Id, String> mapStatusPorIdDocumento){
        for(Id idDocumento : mapStatusPorIdDocumento.keySet()) {
            Documento__c documento = DocumentoSelector.obterDocumentoPorId(idDocumento);

            documento.StatusAprovacao__c = mapStatusPorIdDocumento.get(idDocumento);
            update documento;
        }
    }

    @AuraEnabled
    public static void adicionarObservacoesDocumento(Id idDocumento, String observacoes){
        Documento__c documento = DocumentoSelector.obterDocumentoPorId(idDocumento);

        documento.Observacoes__c = observacoes;
        update documento;
    }
}