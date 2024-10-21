public class ViaCEPCalloutMock implements HttpCalloutMock {
    public static final String CEP = '01001-000';
    public static final String LOGRADOURO = 'Praça da Sé';
    public static final String BAIRRO = 'Sé';
    public static final String LOCALIDADE = 'São Paulo';
    public static final String UF = 'SP';
    public static final String IBGE = '3550308';
    public static final String GIA = '1004';
    public static final String DDD = '11';
    public static final String SIAFI = '7107';

    private Boolean sucesso = true;

    public ViaCEPCalloutMock(Boolean sucesso) {
        this.sucesso = sucesso;
    }

    public HttpResponse respond(HttpRequest req) {
        return this.sucesso ? this.buscarEnderecoComSucesso() : this.buscarEnderecoComFalha();
    }

    private HttpResponse buscarEnderecoComFalha() {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(404);
        response.setStatus('Not Found');

        return response;
    }

    private HttpResponse buscarEnderecoComSucesso() {
        HttpResponse response = new HttpResponse();

        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(new Map<String, Object>{
            'cep' => CEP,
            'logradouro' => LOGRADOURO,
            'bairro' => BAIRRO,
            'localidade' => LOCALIDADE,
            'uf' => UF,
            'ibge' => IBGE,
            'gia' => GIA,
            'ddd' => DDD,
            'siafi' => SIAFI
        }));

        return response;
    }
}