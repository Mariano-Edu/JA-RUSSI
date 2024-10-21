public class IconeStatusDocumentoService {
    static Map<String, String> mapStatusIconeStatus = new Map<String, String> {
        'Não Entregue' => '/resource/NaoEntregueIconResource',
        'Entregue' => '/resource/EntregueIconResource',
        'Reprovado' => '/resource/ReprovadoIconResource',
        'Em Análise' => '/resource/EmAnaliseIconResource',
        'Vencido' => '/resource/ReprovadoIconResource',
        'Aprovado' => '/resource/AprovadoIconResource'
    };

    public static void atualizarIconeStatusDocumento(List<Documento__c> documentosNovos, Map<Id, Documento__c> documentosAntigos) {
        for(Documento__c documento : documentosNovos) {
            if(documento.StatusAprovacao__c != documentosAntigos.get(documento.Id).StatusAprovacao__c) {
                documento.StatusIcone__c = mapStatusIconeStatus.get(documento.StatusAprovacao__c);
            }
        }
    }
}