@isTest
public class GeradorVariaveisControllerTest {

    public static final String CAMPO_API = 'Name';
    public static final String OBJETO_API = 'Account';
    public static final String RELACIONAMENTO_API = 'OwnerId';
    public static final String RELACIONAMENTO_POSTERIOR_API = 'ProfileId';

    @isTest
    static void testObterObjetosOrganizacao() {
        Test.startTest();
        Map<String, String> result = GeradorVariaveisController.obterObjetosOrganizacao();
        Test.stopTest();

        Assert.areNotEqual(0, result.size(), 'O mapa de objetos deve conter elementos.');
        Assert.isTrue(result.containsKey(OBJETO_API), 'O objeto Account deve estar presente no resultado.');
    }

    @isTest
    static void testObterCamposPorObjeto() {
        Test.startTest();
        Map<String, GeradorVariaveisController.DadosRelacionamentoPosterior> result = GeradorVariaveisController.obterCamposPorObjeto(OBJETO_API);
        Test.stopTest();

        Assert.areNotEqual(0, result.size(), 'O mapa de campos deve conter elementos.');
        Assert.isTrue(result.containsKey(CAMPO_API), 'O campo Name deve estar presente no resultado.');
    }

    @isTest
    static void testObterRelacionamento() {
        Test.startTest();
        Map<String, GeradorVariaveisController.DadosRelacionamentoPosterior> result = GeradorVariaveisController.obterRelacionamento(RELACIONAMENTO_API, OBJETO_API);
        Test.stopTest();

        Assert.areNotEqual(0, result.size(), 'O mapa de relacionamentos deve conter elementos.');
        Assert.isTrue(result.containsKey(CAMPO_API), 'O campo Name do objeto User deve estar presente no resultado.');
    }

    @isTest
    static void testObterRelacionamentoPosterior() {
        Test.startTest();
        Map<String, GeradorVariaveisController.DadosRelacionamentoPosterior> result = GeradorVariaveisController.obterRelacionamentoPosterior(OBJETO_API, RELACIONAMENTO_API, RELACIONAMENTO_POSTERIOR_API);
        Test.stopTest();

        Assert.areNotEqual(0, result.size(), 'O mapa de relacionamentos posteriores deve conter elementos.');

        for (String key : result.keySet()) {
            GeradorVariaveisController.DadosRelacionamentoPosterior dados = result.get(key);
            Assert.areNotEqual(null, dados.rotulo, 'O rótulo não deve ser nulo.');
            Assert.areNotEqual(null, dados.objetoRelacionado, 'O objeto relacionado não deve ser nulo.');
        }
    }
}