public with sharing class QuoteService {
    private static final Id SERIE_RECORD_TYPE_ID = Schema.SObjectType.SeriePagamentos__c.getRecordTypeInfosByDeveloperName()
    .get('SerieCotacao')
    .getRecordTypeId();

    public static void handleConcluirSimulacao(
        List<SeriePagamentos__c> series,
        List<QuoteLineItem> qlis,
        Id idCotacao,
        Boolean isParaAprovacao,
        Double valorUnidadeTabela,
        List<OpportunityTeamMember> equipeDefault,
        List<OpportunityTeamMember> equipeVendas
    ) {

        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : qlis) {
            productIds.add(qli.Product2Id);
        }

        Map<Id, Id> pbEntryProductMap = new Map<Id, Id>();
        for (PricebookEntry pbEntry : [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds]) {
            pbEntryProductMap.put(pbEntry.Product2Id, pbEntry.Id);
        }

        for (QuoteLineItem qli : qlis) {
            qli.PricebookEntryId = pbEntryProductMap.get(qli.Product2Id);
        }
        
        for (SeriePagamentos__c serie : series) {
            serie.RecordTypeId = SERIE_RECORD_TYPE_ID;
        }

        insert qlis;
        insert series;

        Quote quoteToUpdate = new Quote(
            Id = idCotacao, 
            Status = 'Em Aprovação', 
            PrecoLista__c = valorUnidadeTabela,
            ComissaoConformeTabela__c = comissaoConformeTabela(equipeDefault, equipeVendas), 
            DescontoConformeTabela__c = !isParaAprovacao
        );

        update quoteToUpdate;
        handleEquipeVendas(equipeVendas);
    }

    private static void handleEquipeVendas(List<OpportunityTeamMember> equipe) {
        Id oppId = equipe[0].OpportunityId;

        List<OpportunityTeamMember> membrosToDelete = OpportunityTeamMemberService.getMembrosToDelete(oppId);

        for(OpportunityTeamMember iMember : equipe) {
            iMember.Id = null;
        }

        if(!membrosToDelete.isEmpty()) {
            delete membrosToDelete;
        }

        insert equipe;
    }

    public static List<QuoteLineItem> criarQuoteLineItems(List<QuoteLineItem> qlis) {
        insert qlis;
        return qlis;
    }

    public static List<SeriePagamentos__c> buscarSeriesPorCotacao(Id idCotacao) {
        return [SELECT 
            Id,
            TipoCondicao__c,
            InicioPagamento__c,
            QuantidadeParcelas__c,
            ValorTotal__c,
            ValorTotalNominal__c,
            DiaVencimentoParcela__c
        FROM SeriePagamentos__c WHERE Cotacao__c = :idCotacao];
    }

    private static Boolean comissaoConformeTabela(List<OpportunityTeamMember> equipeDefault, List<OpportunityTeamMember> equipeVendas) {
        if(equipeDefault.isEmpty() || equipeDefault.size() != equipeVendas.size()) {
            return false;
        }

        Set<String> cargos = ObjectHelper.getFieldValuesFromList(equipeVendas, 'TeamMemberRole');

        Map<String,OpportunityTeamMember> equipeDefaultPorCargo = getMembrosPorCargo(equipeDefault);
        Map<String,OpportunityTeamMember> equipeSimuladorPorCargo = getMembrosPorCargo(equipeVendas);


        for(String iCargo : cargos) {
            OpportunityTeamMember membroDefault = equipeDefaultPorCargo.get(iCargo);
            OpportunityTeamMember membroSimulador = equipeSimuladorPorCargo.get(iCargo);

            if(isComissaoNotEqual(membroDefault, membroSimulador)) {
                return false;
            }
        }
        

        return true;
    }

    private static Boolean isComissaoNotEqual(OpportunityTeamMember iMembro, OpportunityTeamMember jMembro) {
        return iMembro.UserId != jMembro.UserId ||
            iMembro.ValorComissao__c != jMembro.ValorComissao__c ||
            iMembro.PercentualComissao__c != jMembro.PercentualComissao__c || 
            iMembro.ValorPremio__c != jMembro.ValorPremio__c ;
    }

    private static Map<String,OpportunityTeamMember> getMembrosPorCargo(List<OpportunityTeamMember> equipe) {
        Map<String,OpportunityTeamMember> membrosPorCargo = new Map<String,OpportunityTeamMember>();

        for(OpportunityTeamMember iMembro : equipe) {
            membrosPorCargo.put(iMembro.TeamMemberRole, iMembro);
        }

        return membrosPorCargo;
    }
}