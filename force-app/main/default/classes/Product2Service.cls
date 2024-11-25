public with sharing class Product2Service {
    // public static List<Product2> getVagasPorEmpreendimento(Id idEmpreendimento) {
    //     return ProdutoSelector.getVagasPorIdEmpreendimento(idEmpreendimento);
    // }

    public static List<Product2> getVagasGaragem(Id idEmpreendimento) {
        
        return ProdutoSelector.getVagasGaragem(idEmpreendimento);
    }

    public static List<Product2> getQtdVagas(Id idUnidade) {
        
        return ProdutoSelector.getQtdVagas(idUnidade);
    }
}