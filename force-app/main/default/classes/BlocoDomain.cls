public class BlocoDomain {
    public static Map<String, Bloco__c> obterBlocosEmpreendimentoPorChaveExterna(Id idEmpreendimento) {
        List<Bloco__c> blocos = BlocoSelector.obterBlocosPorIdsEmpreendimentos(new Set<Id>{ idEmpreendimento });

        return obterBlocosPorChaveExterna(blocos);
    }

    public static Map<String, Bloco__c> obterBlocosPorChaveExterna(List<Bloco__c> blocos) {
        Map<String, Bloco__c> blocosPorChaveExterna = new Map<String, Bloco__c>();
        for(Bloco__c bloco : blocos) {
            blocosPorChaveExterna.put(bloco.ChaveExterna__c, bloco);
        }

        return blocosPorChaveExterna;
    }
}