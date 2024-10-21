@RestResource(urlMapping='/Empreendimentos/')
global class EmpreendimentoRestResource {
    
    @HttpGet
    global static List<EmpreendimentoResponse> getEmpreendimentos() {
        return EmpreendimentoHelper.getEmpreendimentosResponse();
    }
}