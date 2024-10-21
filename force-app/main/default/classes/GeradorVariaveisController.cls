public with sharing class GeradorVariaveisController {
    
    @AuraEnabled
    public static Map<String, String> obterObjetosOrganizacao(){
        Map<String, String> objetosEncontrados = new Map<String, String>();
        Map<String, Schema.SObjectType> organizacao = Schema.getGlobalDescribe();
        
        for(String objetoAPI : organizacao.keySet()){
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objetoAPI}); // this can accept list of strings, we describe only one object here
            String rotuloObjeto = describeSobjectsResult[0].getLabel();
            String apiObjeto = describeSobjectsResult[0].getName();

            objetosEncontrados.put(apiObjeto, rotuloObjeto);
        }

        return objetosEncontrados;
    }

    @AuraEnabled
    public static Map<String, DadosRelacionamentoPosterior> obterCamposPorObjeto(String objetoAPI){
        Map<String, DadosRelacionamentoPosterior> camposEncontrados = new Map<String, DadosRelacionamentoPosterior>();
        Map<String, Schema.SObjectType> organizacao = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> camposMapeados = organizacao.get(objetoAPI).getDescribe().fields.getMap();
        
        for(String campoAPI : camposMapeados.keyset()){    
            String rotuloCampo = Schema.getGlobalDescribe().get(objetoAPI).getDescribe().fields.getMap().get(campoAPI).getDescribe().getLabel();
            String apiCampo = Schema.getGlobalDescribe().get(objetoAPI).getDescribe().fields.getMap().get(campoAPI).getDescribe().getName();
            Schema.DisplayType tipoCampo = Schema.getGlobalDescribe().get(objetoAPI).getDescribe().fields.getMap().get(campoAPI).getDescribe().getType();
            
            DadosRelacionamentoPosterior dados = new DadosRelacionamentoPosterior();
            dados.rotulo = rotuloCampo;
            dados.tipoCampo = String.valueOf(tipoCampo);

            camposEncontrados.put(apiCampo, dados);
        }
        return camposEncontrados;
    }

    @AuraEnabled
    public static Map<String, DadosRelacionamentoPosterior> obterRelacionamento(String campoAPI, String objetoAPI){
        Map<String, DadosRelacionamentoPosterior> relacionamentosEncontrados = new Map<String, DadosRelacionamentoPosterior>();
        Map<String, Schema.SObjectType> organizacao = Schema.getGlobalDescribe();
        List<Schema.SObjectType> objetoRelacionado = Schema.getGlobalDescribe().get(objetoAPI).getDescribe().fields.getMap().get(campoAPI).getDescribe().getReferenceTo();
        String objetoPesquisa = '' + objetoRelacionado[0]  + '';

        Map<String, Schema.SObjectField> camposMapeados = organizacao.get(objetoPesquisa).getDescribe().fields.getMap();
        for(String releacionamentoAPI : camposMapeados.keyset()){    
            String rotuloCampo = Schema.getGlobalDescribe().get(objetoPesquisa).getDescribe().fields.getMap().get(releacionamentoAPI).getDescribe().getLabel();
            String apiCampo = Schema.getGlobalDescribe().get(objetoPesquisa).getDescribe().fields.getMap().get(releacionamentoAPI).getDescribe().getName();
            Schema.DisplayType tipoCampo = Schema.getGlobalDescribe().get(objetoPesquisa).getDescribe().fields.getMap().get(releacionamentoAPI).getDescribe().getType();
            
            DadosRelacionamentoPosterior dados = new DadosRelacionamentoPosterior();
            dados.rotulo = rotuloCampo;
            dados.tipoCampo = String.valueOf(tipoCampo);
            dados.objetoRelacionado = objetoPesquisa;

            relacionamentosEncontrados.put(apiCampo, dados);
        }
        return relacionamentosEncontrados;
    }

    @AuraEnabled
    public static Map<String, DadosRelacionamentoPosterior> obterRelacionamentoPosterior(String objetoAPI, String campoAPI, String relacionamentoAPI){
        Map<String, DadosRelacionamentoPosterior> relacionamentosEncontrados = new Map<String, DadosRelacionamentoPosterior>();
        Map<String, Schema.SObjectType> organizacao = Schema.getGlobalDescribe(); 
        List<Schema.SObjectType> objetoRelacionado = Schema.getGlobalDescribe().get(objetoAPI).getDescribe().fields.getMap().get(campoAPI).getDescribe().getReferenceTo();
        String objetoPesquisa = '' + objetoRelacionado[0]  + '';

        List<Schema.SObjectType> objetoRelacionadoPosterior = Schema.getGlobalDescribe().get(objetoPesquisa).getDescribe().fields.getMap().get(relacionamentoAPI).getDescribe().getReferenceTo();
        String objetoPesquisaPosterior = '' + objetoRelacionadoPosterior[0]  + '';

        Map<String, Schema.SObjectField> camposMapeados = organizacao.get(objetoPesquisaPosterior).getDescribe().fields.getMap();
        for(String keyAPI : camposMapeados.keyset()){
            String rotuloCampo = Schema.getGlobalDescribe().get(objetoPesquisaPosterior).getDescribe().fields.getMap().get(keyAPI).getDescribe().getLabel();
            String apiCampo = Schema.getGlobalDescribe().get(objetoPesquisaPosterior).getDescribe().fields.getMap().get(keyAPI).getDescribe().getName();
            Schema.DisplayType tipoCampo = Schema.getGlobalDescribe().get(objetoPesquisaPosterior).getDescribe().fields.getMap().get(keyAPI).getDescribe().getType();

            DadosRelacionamentoPosterior dados = new DadosRelacionamentoPosterior();
            dados.rotulo = rotuloCampo;
            dados.objetoRelacionado = objetoPesquisa;
            dados.objetoPesquisa = objetoPesquisaPosterior;
            dados.tipoCampo = String.valueOf(tipoCampo);
                        
            relacionamentosEncontrados.put(apiCampo, dados);
        }
        return relacionamentosEncontrados;
    }

    public class DadosRelacionamentoPosterior {
        @AuraEnabled 
        public String rotulo {get; set;}
        @AuraEnabled 
        public String objetoRelacionado {get; set;} 
        @AuraEnabled 
        public String objetoPesquisa {get; set;} 
        @AuraEnabled 
        public String tipoCampo {get; set;}
    }
}