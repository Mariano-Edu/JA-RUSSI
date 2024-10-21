public class SimuladorVendasController {
    //Metodo para desenvolviment
        @AuraEnabled(cacheable = true)
        public static Product2 buscarProdutoPorId(Id id){
            return ProdutoSelector.getProdutosById(id);
        }
        
        @AuraEnabled(cacheable = true)
        public static PricebookEntry buscarEntradaTabelaPrecoPorIdDeProduto(Id id){
            return EntradaTabelaPrecoSelector.getEntradaTabelaPrecoByProdutoId(id);
        }
        
        @AuraEnabled(cacheable = true)
        public static List<TabelaVendas__c> obterTabelasPorIdEmpreendimento(Id idEmpreendimento){
            return TabelaVendaSelector.obterTabelasPorIdEmpreendimento(idEmpreendimento);
        }
    }