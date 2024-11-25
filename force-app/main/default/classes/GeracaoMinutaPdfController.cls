public with sharing class GeracaoMinutaPdfController {
    public String conteudo {get;set;}

    public GeracaoMinutaPdfController() {
        String minutaId = ApexPages.currentPage().getParameters().get('minutaId');
        String fileRefId = ApexPages.currentPage().getParameters().get('fileRefId');
        String obj_refs = ApexPages.currentPage().getParameters().get('obj_refs');

        List<Id> obj_refs_list = (List<Id>)JSON.deserialize(obj_refs, List<Id>.class);
        if(obj_refs_list.isEmpty()){
            conteudo = GeracaoMinutaService.gerarConteudo(minutaId,fileRefId);
        } else {
            conteudo = GeracaoMinutaService.gerarConteudo(minutaId,fileRefId,obj_refs_list);
        }
    }
}