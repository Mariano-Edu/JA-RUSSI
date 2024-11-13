public with sharing class Product2Service {
    // public static List<Product2> getVagasPorEmpreendimento(Id idEmpreendimento) {
    //     return ProdutoSelector.getVagasPorIdEmpreendimento(idEmpreendimento);
    // }

    public static List<Product2> getVagasGaragem(Id idEmpreendimento) {
        System.debug(idEmpreendimento);
        return ProdutoSelector.getVagasGaragem(idEmpreendimento);
    }
}