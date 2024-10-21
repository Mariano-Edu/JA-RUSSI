public with sharing class UnidadeTabelaService {
    public static void updateOpportunitiesFromQuotes(List<UnidadeTabelaVendas__c> novaUnidadeTabela, Map<Id, UnidadeTabelaVendas__c> oldMap) {
        List<Product2> ProdutosParaAtualizar = new List<Product2>();
        Set<Id> IdsUnidade = new Set<Id>();

        for (UnidadeTabelaVendas__c unidade : novaUnidadeTabela) {
            if (unidade.CoeficienteTabela__c != oldMap.get(unidade.Id).CoeficienteTabela__c) {
                IdsUnidade.add(unidade.Unidade__c);
            }
        }

        if (!IdsUnidade.isEmpty()) {
            Map<Id, Product2> produtoParaAtualizar = ProdutoSelector.CoeficienteProdutoPorId(new List<Id>(IdsUnidade));
            for (UnidadeTabelaVendas__c unidadeTabela : novaUnidadeTabela) {
                if (produtoParaAtualizar.containsKey(unidadeTabela.Unidade__c)) {
                    Product2 produto = produtoParaAtualizar.get(unidadeTabela.Unidade__c);
                    produto.Coeficiente__c = unidadeTabela.CoeficienteTabela__c;
                    ProdutosParaAtualizar.add(produto);
                }
            }
            if (!ProdutosParaAtualizar.isEmpty()) {
                update ProdutosParaAtualizar;
            }
        }
    }
}