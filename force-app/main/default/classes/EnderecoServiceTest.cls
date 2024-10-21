@isTest
public class EnderecoServiceTest {
    static final String MENSAGEM_ERRO = String.format(System.Label.ErroConsultarCEP, new List<String>{ 'Not Found', '404' });
    static final String OBJECT_API_NAME = 'Account';
    static final String NOME_CONTA = 'Test Account';
    static final String RUA = 'Rua Antiga';
    static final String CIDADE = 'Cidade Antiga';
    static final String ESTADO = 'Estado Antigo';
    static final String CEP = '01001000';
    static final Map<String, String> ENDERECO = new Map<String, String>{
        'BillingStreet' => RUA,
        'BillingCity' => ViaCEPCalloutMock.LOCALIDADE,
        'BillingState' => ViaCEPCalloutMock.UF,
        'BillingPostalCode' => ViaCEPCalloutMock.CEP
    };

    @TestSetup
    static void makeData() {
        Account conta = new Account(
            Name = NOME_CONTA, 
            BillingStreet = RUA,
            BillingCity = CIDADE,
            BillingState = ESTADO,
            BillingPostalCode = CEP,
            CNPJ__c = '41956129000155'
        );
        insert conta;
    }

    @isTest
    static void testBuscarEnderecoSuccess() {
        EnderecoDTO enderecoEsperado = criarEnderecoEsperado();

        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(true));
        Test.startTest();

        String resultado = EnderecoService.buscarEndereco(CEP);

        Test.stopTest();

        EnderecoDTO endereco = (EnderecoDTO) JSON.deserialize(resultado, EnderecoDTO.class);

        Assert.areEqual(enderecoEsperado.logradouro, endereco.logradouro, 'Logradouro obtido via CEP.');
    }

    @isTest
    static void testObterEnderecoError() {
        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(false));

        try {
            Test.startTest();

            EnderecoService.buscarEndereco(CEP);

            Test.stopTest();
        } catch (CalloutException e) {
            Assert.areEqual(MENSAGEM_ERRO, e.getMessage(), 'Ocorreu um erro ao buscar CEP.');
        }
    }

    @isTest
    static void testModificarEndereco() {
        Account conta = [SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account LIMIT 1];

        EnderecoService.modificarEndereco(JSON.serialize(ENDERECO), OBJECT_API_NAME, conta.Id);

        Account contaAtualizada = [SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id = :conta.Id];

        Assert.areEqual(RUA, contaAtualizada.BillingStreet, 'Rua atualizada.');
        Assert.areEqual(ViaCEPCalloutMock.LOCALIDADE, contaAtualizada.BillingCity, 'Cidade atualizada.');
        Assert.areEqual(ViaCEPCalloutMock.UF, contaAtualizada.BillingState, 'Estado atualizado.');
        Assert.areEqual(ViaCEPCalloutMock.CEP, contaAtualizada.BillingPostalCode, 'CEP atualizado.');
    }

    @isTest
    static void testObterRegistro() {
        Account conta = [SELECT Id FROM Account LIMIT 1];

        String registroJSON = EnderecoService.obterRegistro(new List<String>(ENDERECO.keySet()), OBJECT_API_NAME, conta.Id);

        Account contaObtida = (Account) JSON.deserialize(registroJSON, Account.class);

        Assert.areEqual(CIDADE, contaObtida.BillingCity, 'Cidade da conta obtida com sucesso.');
        Assert.areEqual(ESTADO, contaObtida.BillingState, 'Estado da conta obtido com sucesso.');
        Assert.areEqual(CEP, contaObtida.BillingPostalCode, 'CEP da conta obtido com sucesso.');
    }

    static EnderecoDTO criarEnderecoEsperado() {
        return (EnderecoDTO) JSON.deserialize((new ViaCEPCalloutMock(true)).respond(null).getBody(), EnderecoDTO.class);
    }

    @isTest
    private static void buscarEnderecoInvocableTest() {

        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(true));


        EnderecoService.EnderecoRequest request = new EnderecoService.EnderecoRequest();
        request.cep = '01001000';

        List<EnderecoService.EnderecoRequest> enderecoRequests = new List<EnderecoService.EnderecoRequest>{
            request
        };

        Test.startTest();
        List<EnderecoService.EnderecoResponse> responses = EnderecoService.buscarEnderecoInvocable(enderecoRequests);
        System.debug(responses);
        Test.stopTest();
        Assert.isFalse(responses.isEmpty());
        EnderecoService.EnderecoResponse response = responses[0];
        Assert.areEqual('Praça da Sé', response.logradouro, 'Logradouro deve ser "Praça da Sé".');
        Assert.areEqual('Sé', response.bairro, 'Bairro deve ser "Sé".');
        Assert.areEqual('SP', response.uf, 'UF deve ser "SP".');
        Assert.areEqual('01001-000', response.cep, 'CEP deve ser "01001-000".');
        Assert.areEqual('São Paulo', response.cidade, 'Cidade deve ser "São Paulo".');

    }
}