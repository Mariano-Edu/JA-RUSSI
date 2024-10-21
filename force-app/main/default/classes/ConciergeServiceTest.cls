@isTest
private class ConciergeServiceTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        List<Lead> leads = new List<Lead>{
            new Lead(
                LastName = 'Teste1',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                Email = 'teste1@teste.com',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '15',
                Phone = '18845-6789',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '15',
                Celular__c = '18845-6789',
                Status = 'New'
            ),

            new Lead(
                LastName = 'Teste2',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                Email = 'teste2@teste.com',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c= '18835-6789',
                DDITelefone__c = 'Brasil (+55)',
                DDDTelefone__c = '16',
                Phone = '18845-6789',
                Status = 'New'
            )
        };

        insert leads;
    }

    @isTest
    static void obterCanaisAtendimentoTest() {
        Map<String, String> canaisAtendimentoPorValor = new Map<String, String>();
        
        for(Schema.PicklistEntry opcaoCanalAtendimento : Lead.CanalAtendimento__c.getDescribe().getPicklistValues()) {
            canaisAtendimentoPorValor.put(opcaoCanalAtendimento.getValue(), opcaoCanalAtendimento.getLabel());
        }
        
        Assert.areEqual(canaisAtendimentoPorValor, ConciergeService.obterCanaisAtendimento());
    }

    @isTest
    static void obterOrigensTest() {
        Map<String, String> origensPorValor = new Map<String, String>();

        for(Schema.PicklistEntry opcaoOrigem : Lead.LeadSource.getDescribe().getPicklistValues()) {
            origensPorValor.put(opcaoOrigem.getValue(), opcaoOrigem.getLabel());
        }


        Assert.areEqual(origensPorValor, ConciergeService.obterOrigens());
    }

    @isTest
    static void obterDDIsTest() {
        Map<String, String> ddisPorValor = new Map<String, String>();

        for(Schema.PicklistEntry opcaoDDI : Lead.DDICelular__c.getDescribe().getPicklistValues()) {
            ddisPorValor.put(opcaoDDI.getValue(), opcaoDDI.getLabel());
        }

        Assert.areEqual(ddisPorValor, ConciergeService.obterDDIs());
    }

    @isTest
    static void obterMidiasTest() {
        Map<String,String> midiasAtuaisPorValor = new Map<String,String>();

        for(Schema.PicklistEntry opcaoMidia : Lead.MidiaAtual__c.getDescribe().getPicklistValues()) {
            midiasAtuaisPorValor.put(opcaoMidia.getValue(), opcaoMidia.getLabel());
        }

        Assert.areEqual(midiasAtuaisPorValor, ConciergeService.obterMidias());
    }

    @isTest
    static void obterLeadsPorInformacoesConciergeTest() {
        List<Lead> leads = [SELECT LastName, DDICelular__c, MobilePhone, CelularFormatado__c, DDDTelefone__c, Phone, TelefoneFormatado__c, Owner.Name FROM Lead WHERE LastName = 'Teste1'];

        Map<String,String> formulario = new Map<String,String>();
        formulario.put('nome', 'Teste1');

        List<LeadDTO> leadsDTO = (List<LeadDTO>) JSON.deserialize(ConciergeService.obterLeadsPorInformacoesConcierge(formulario), List<LeadDTO>.class);

        Assert.areEqual(1, leadsDTO.size());
    }

    @isTest
    static void criarLeadPfTest() {
        String pfRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName().get('Pessoa Física').getRecordTypeId();

        Map<String, String> formulario = new Map<String,String> {
            'nome'=> null,
            'ddiCel'=> 'Brasil (+55)',
            'ddiTel'=> 'Brasil (+55)',
            'dddCel'=> '11',
            'dddTel'=> '11',
            'celular'=> '98765-4321',
            'midia'=> 'Anúncio Loja',
            'email'=> 'emailTeste@email.com',
            'origem'=> 'Outros',
            'canal'=> 'Chat',
            'telefone'=> '8765-4321',
            'recordType' => pfRecordTypeId
        };

        Assert.isNull(ConciergeService.criarLead(formulario));

        formulario.put('nome', 'Teste1');

        Id idLeadCriado = ConciergeService.criarLead(formulario);
        Lead leadCriado = [SELECT Id FROM Lead WHERE Id = :idLeadCriado].get(0);

        Assert.isNotNull(leadCriado);
    }

    @isTest
    static void criarLeadPjTest() {
        String pjRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName().get('Pessoa Jurídica').getRecordTypeId();

        Map<String, String> formulario = new Map<String,String> {
            'nome'=> 'Teste2',
            'ddiCel'=> 'Brasil (+55)',
            'ddiTel'=> 'Brasil (+55)',
            'dddCel'=> '11',
            'dddTel'=> '11',
            'celular'=> '98765-4322',
            'midia'=> 'Anúncio Loja',
            'email'=> 'emailTeste2@email.com',
            'origem'=> 'Outros',
            'canal'=> 'Chat',
            'telefone'=> '8765-4322',
            'recordType' => pjRecordTypeId
        };

        Id idLeadCriado = ConciergeService.criarLead(formulario);
        Lead leadCriado = [SELECT Id FROM Lead WHERE Id = :idLeadCriado].get(0);

        Assert.isNotNull(leadCriado);
    }
}