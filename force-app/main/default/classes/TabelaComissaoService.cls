public class TabelaComissaoService {
    public static List<TabelaComissao__c> getTabelasComissao(Id idTabela, Id idEmpreendimento, String empresaVenda) {
        if(empresaVenda == 'House') {
            return TabelaComissaoSelector.getTabelasComissao(idTabela, idEmpreendimento, empresaVenda);
        }

        List<TabelaComissao__c> tabelas = TabelaComissaoSelector.getTabelasComissao(idTabela, idEmpreendimento, empresaVenda);
    
        if(tabelas.isEmpty()) {
            tabelas = TabelaComissaoSelector.getTabelasComissao(idTabela, idEmpreendimento, 'House');
        }

        return tabelas;
    }
}