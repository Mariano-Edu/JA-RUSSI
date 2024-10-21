@isTest
private class ConciergeControllerTest {
    
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData() {
        insert new List<Lead>{
            new Lead(
                LastName = 'Teste1',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '16',
                Celular__c= '18845-6789',
                Email = 'email2@Teste.com',
                Phone = '12345-6789',
                DDITelefone__c = 'Afeganistão (+93)',
                DDDTelefone__c = '55'
            ),
            new Lead(
                LastName = 'Teste2',
                LeadSource = 'Site',
                MidiaAtual__c = 'Instagram',
                CanalAtendimento__c = 'Chat',
                Email = 'email@Teste.com',
                DDICelular__c = 'Brasil (+55)',
                DDDCelular__c = '15',
                Celular__c= '18845-6789',
                Phone = '78548-4782',
                DDITelefone__c = 'Afeganistão (+93)',
                DDDTelefone__c = '55'
            )
        };
    }

    @isTest
    private static void obterCanaisAtendimentoTest() {
        Map<String, String> expectedCanais = new Map<String, String>();
        
        for(Schema.PicklistEntry opcaoCanalAtendimento : Lead.CanalAtendimento__c.getDescribe().getPicklistValues()) {
            expectedCanais.put(opcaoCanalAtendimento.getValue(), opcaoCanalAtendimento.getLabel());
        }

        Assert.areEqual(expectedCanais, ConciergeController.obterCanaisAtendimento());
    }

    @isTest
    private static void obterOrigens() {
        Map<String, String> expectedOrigens = new Map<String, String>();

        for(Schema.PicklistEntry opcaoOrigem : Lead.LeadSource.getDescribe().getPicklistValues()) {
            expectedOrigens.put(opcaoOrigem.getValue(), opcaoOrigem.getLabel());
        }

        Assert.areEqual(expectedOrigens, ConciergeController.obterOrigens());
    }

    @isTest
    private static void obterDDIsTeste() {
        Map<String, String> expectedDDIs = new Map<String, String>();

        for(Schema.PicklistEntry opcaoDDI : Lead.DDICelular__c.getDescribe().getPicklistValues()) {
            expectedDDIs.put(opcaoDDI.getValue(), opcaoDDI.getLabel());
        }

        Assert.areEqual(expectedDDIs, ConciergeController.obterDDIs());
    }

    @isTest
    private static void obterMidias() {
        Map<String,String> expectedMidias = new Map<String,String>();

        for(Schema.PicklistEntry opcaoMidia : Lead.MidiaAtual__c.getDescribe().getPicklistValues()) {
            expectedMidias.put(opcaoMidia.getValue(), opcaoMidia.getLabel());
        }

        Assert.areEqual(expectedMidias, ConciergeController.obterMidias());
    }

    @isTest
    private static void obterLeadsPorInformacoesConciergePorNomeTest() {
        Map<String, String> formulario = new Map<String,String> {
            'nome' => 'Teste'
        };

        List<LeadDTO> leadsDTO = (List<LeadDTO>) JSON.deserialize(
            ConciergeService.obterLeadsPorInformacoesConcierge(formulario),
            List<LeadDTO>.class
        );

        Assert.isFalse(leadsDTO.isEmpty());
        Assert.isTrue(leadsDTO.size() == 2);
    }

    @isTest
    private static void obterLeadsPorInformacoesConciergePorTelefoneTest() {
        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Teste',
            'telefone' => '12345'
        };

        List<LeadDTO> leadsDTO = (List<LeadDTO>) JSON.deserialize(
            ConciergeService.obterLeadsPorInformacoesConcierge(formulario),
            List<LeadDTO>.class
        );
        
        Assert.isFalse(leadsDTO.isEmpty());
        Assert.isTrue(leadsDTO.size() == 1);
    }

    @isTest
    private static void obterLeadsPorInformacoesConciergePorEmailTest() {
        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Teste',
            'email' => 'email'
        };

        List<LeadDTO> leadsDTO = (List<LeadDTO>) JSON.deserialize(
            ConciergeService.obterLeadsPorInformacoesConcierge(formulario),
            List<LeadDTO>.class
        );
        
        Assert.isFalse(leadsDTO.isEmpty());
        Assert.isTrue(leadsDTO.size() == 2);
    }

    @isTest
    private static void criarLeadPfTest() {
        String pfRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName().get('Pessoa Física').getRecordTypeId();

        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Robinson Guimarães',
            'email' => 'emailTeste3@email.com',
            'recordType' => pfRecordTypeId,
            'origem' => 'Outros',
            'midia' => 'Anúncio Loja',
            'canal' => 'Chat'
        };

        Id idLeadCriado = ConciergeController.criarLead(formulario);

        Lead leadCriado = [SELECT Id FROM Lead WHERE Id = :idLeadCriado].get(0);
        Assert.isNotNull(leadCriado);
    }

    @isTest
    private static void criarLeadPjTest() {
        String pjRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName().get('Pessoa Jurídica').getRecordTypeId();

        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Inteligencia limitada',
            'email' => 'emailTeste50@email.com',
            'recordType' => pjRecordTypeId,
            'origem' => 'Outros',
            'midia' => 'Anúncio Loja',
            'canal' => 'Chat'
        };

        Id idLeadCriado = ConciergeController.criarLead(formulario);

        Lead leadCriado = [SELECT Id FROM Lead WHERE Id = :idLeadCriado].get(0);
        Assert.isNotNull(leadCriado);
    }

    @isTest
    private static void criarLeadExceptionTest() {
        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Inteligencia limitada',
            'email' => 'emailTeste50@email.com',
            'origem' => 'Outros',
            'midia' => 'Anúncio Loja',
            'canal' => 'Chat',
            'telefone' => '1231323123'
        };

        Assert.isNull(ConciergeController.criarLead(formulario));
    }

    @isTest
    public static void obterLeadsPorInformacoesConciergeTest() {
        String pfRecordTypeId = Schema.SObjectType.Lead
            .getRecordTypeInfosByName().get('Pessoa Física').getRecordTypeId();

        Map<String,String> formulario = new Map<String,String> {
            'nome' => 'Teste1'
        };

        Test.startTest();
        String informacoes = ConciergeController.obterLeadsPorInformacoesConcierge(formulario);
        Test.stopTest();
        
        Assert.AreNotEqual(informacoes, '[]');
    }
}