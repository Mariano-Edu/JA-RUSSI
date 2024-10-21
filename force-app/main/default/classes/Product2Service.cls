public with sharing class Product2Service {
    public static List<Product2> getVagasPorEmpreendimento(Id idEmpreendimento) {
        return ProdutoSelector.getVagasPorIdEmpreendimento(idEmpreendimento);
    }
}