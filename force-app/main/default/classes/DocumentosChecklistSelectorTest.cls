@isTest
private class DocumentosChecklistSelectorTest {

    @isTest
    static void buscarConfiguracoesDocumentosChecklistTest() {
        List<ConfiguracaoChecklistDocumentos__mdt> configuracoes = [SELECT Id FROM ConfiguracaoChecklistDocumentos__mdt];

        Test.startTest();
        List<ConfiguracaoChecklistDocumentos__mdt> configuracoesVerificadas = DocumentosChecklistSelector.buscarConfiguracoesDocumentosChecklist();
        Test.stopTest();

        Assert.areEqual(configuracoes.size(), configuracoesVerificadas.size());
    }
}