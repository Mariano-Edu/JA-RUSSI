public class CriacaoDocumentosService {
    public static void criarDocumentosEmCriacaoDeOportunidade(List<Opportunity> oportunidades) {
    	for (Opportunity oportunidade : oportunidades) {
            Account conta = AccountSelector.obterInfoContaPorId(oportunidade.AccountId);
            Account conjuge = conta.Conjuge__pc != null ? AccountSelector.obterInfoContaPorId(conta.Conjuge__pc) : null;
            Boolean possuiConjuge = conjuge != null;
            Decimal porcentagemDeParticipacao = possuiConjuge ? 50.0 : 100.0;
            String tipoParticipante = conta.RecordType.DeveloperName == 'PessoaFisicaPF' ? 'Comprador' : 'Sócio';

            List<Comprador__c> compradoresSelector = CompradorSelector.obterCompradorPorIdConta(conta.Id, oportunidade.Id);
            Comprador__c comprador = compradoresSelector.isEmpty() ? inserirComprador(conta, oportunidade, true, porcentagemDeParticipacao, tipoParticipante) : compradoresSelector.get(0);

            if(!verificarDocumentosExistentes(comprador.Id)) {
                inserirDocumentos(oportunidade.Id, conta.Id, comprador.Id);
            }

            if (!possuiConjuge) {
                return;
            }

            List<Comprador__c> compradoresConjuge = CompradorSelector.obterCompradorPorIdConta(conjuge.Id, oportunidade.Id);
            Comprador__c compradorConjuge = compradoresConjuge.isEmpty() ? inserirComprador(conjuge, oportunidade, false, 50.0, 'Cônjuge/Companheiro') : compradoresConjuge.get(0);

            if(!verificarDocumentosExistentes(compradorConjuge.Id)) {
                inserirDocumentos(oportunidade.Id, conjuge.Id, compradorConjuge.Id);
            }
        }
    }

    public static void criarDocumentosEmCriacaoComprador(List<Comprador__c> compradores) {
        for(Comprador__c comprador : compradores) {
            if(!verificarDocumentosExistentes(comprador.Id)) {
                inserirDocumentos(comprador.Oportunidade__c, comprador.Conta__c, comprador.Id);
            }
        }
    }

    static Boolean verificarDocumentosExistentes(Id idComprador) {
        List<Documento__c> documentosSelector = DocumentoSelector.obterDocumentosPorComprador(idComprador);
        return !(documentosSelector.isEmpty());
    }

    static void inserirDocumentos(Id idOportunidade, Id idConta, Id idComprador) {
            String resourceNaoEntrege = '/resource/NaoEntregueIconResource';

            List<Documento__c> documentos = new List<Documento__c> {
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CNH ou CPF',
                        TipoDocumento__c = 'Identificação',
                        Comprador__c = idComprador,
                        Obrigatorio__c = true,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Certidão de casamento',
                        TipoDocumento__c = 'Identificação',
                        Comprador__c = idComprador,
                        Obrigatorio__c = true,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c(
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Comprovante de Residencia',
                        TipoDocumento__c = 'Identificação',
                        Comprador__c = idComprador,
                        Obrigatorio__c = true,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Contrato Social',
                        TipoDocumento__c = 'Identificação',
                        Comprador__c = idComprador,
                        Obrigatorio__c = true,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Documento de Rodar',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Vistoria Cautelar',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CND do Detran',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Fotos do Veículo',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Foto da KM',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Valor na Fipe',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'DUT',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Procuração',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Termo de Entrega',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Manual',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Chave Reserva',
                        TipoDocumento__c = 'Veículo',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Matricula Atualizada',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CND Condomino',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CND Prefeitura',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CND Lixo',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'CND Água/esgoto',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Boleto Energia',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    ),
                    new Documento__c (
                        Oportunidade__c = idOportunidade,
                        Conta__c = idConta,
                        Name = 'Termo de vistoria recebimento',
                        TipoDocumento__c = 'Imóvel',
                        Comprador__c = idComprador,
                        Obrigatorio__c = false,
                        StatusAprovacao__c = 'Não Entregue',
                        StatusIcone__c = resourceNaoEntrege
                    )
                };
                
            insert documentos;
    }

    static Comprador__c inserirComprador(Account conta, Opportunity oportunidade, Boolean isPrincipal, Decimal porcentagemDeParticipacao, String tipoParticipante) {
        Comprador__c comprador = new Comprador__c (
                Conta__c = conta.Id,
                Oportunidade__c = oportunidade.Id,
                CompradorPrincipal__c = isPrincipal ? 'Sim' : 'Não',
                PorcentagemDeParticipacao__c = porcentagemDeParticipacao,
                TipoParticipante__c = tipoParticipante
        );

        insert comprador;
        return comprador;
    }
}