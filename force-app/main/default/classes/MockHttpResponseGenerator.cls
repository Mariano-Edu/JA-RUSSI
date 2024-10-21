@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implementar o método respond para simular a resposta HTTP
    global HttpResponse respond(HttpRequest req) {
        // Simular uma resposta de sucesso para o ViaCEP
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"cep": "01001-000", "logradouro": "Praça da Sé", "complemento": "lado ímpar", "bairro": "Sé", "localidade": "São Paulo", "uf": "SP", "ibge": "3550308", "gia": "1004", "ddd": "11", "siafi": "7107"}');
        res.setStatusCode(200);
        return res;
    }
}