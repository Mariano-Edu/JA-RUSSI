@isTest
public class ViaCEPCalloutTest {
    static final String MENSAGEM_ERRO = String.format(System.Label.ErroConsultarCEP, new List<String>{ 'Not Found', '404' });
    static final String CEP = '01001000';

    @isTest
    static void testBuscarEnderecoSuccess() {
        EnderecoDTO enderecoEsperado = criarEnderecoEsperado(); 

        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(true));

        HttpResponse response = ViaCEPCallout.buscarEndereco(CEP);
        EnderecoDTO endereco = (EnderecoDTO) JSON.deserialize(response.getBody(), EnderecoDTO.class);

        Assert.areEqual(enderecoEsperado.logradouro, endereco.logradouro, 'Logradouro obtido via CEP.');
    }

    @isTest
    static void testObterEnderecoError() {
        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(false));

        try {
            ViaCEPCallout.buscarEndereco(CEP);
        } catch (CalloutException e) {
            Assert.areEqual(MENSAGEM_ERRO, e.getMessage(), 'Ocorreu um erro ao buscar CEP.');
        }
    }

    static EnderecoDTO criarEnderecoEsperado() {
        return (EnderecoDTO) JSON.deserialize((new ViaCEPCalloutMock(true)).respond(null).getBody(), EnderecoDTO.class);
    }
}