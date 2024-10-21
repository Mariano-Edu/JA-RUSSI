public without sharing class ConciergeService {
    public static Map<String, String> obterCanaisAtendimento() {
        Map<String, String> canaisAtendimentoPorValor = new Map<String, String>();
        
        for(Schema.PicklistEntry opcaoCanalAtendimento : Lead.CanalAtendimento__c.getDescribe().getPicklistValues()) {
            canaisAtendimentoPorValor.put(opcaoCanalAtendimento.getValue(), opcaoCanalAtendimento.getLabel());
        }
        
        return canaisAtendimentoPorValor;
    }
    
    public static Map<String, String> obterOrigens() {
        Map<String, String> origensPorValor = new Map<String, String>();
        
        for(Schema.PicklistEntry opcaoOrigem : Lead.LeadSource.getDescribe().getPicklistValues()) {
            origensPorValor.put(opcaoOrigem.getValue(), opcaoOrigem.getLabel());
        }
        
        return origensPorValor;
    }
    
    public static Map<String, String> obterDDIs() {
        Map<String, String> ddisPorValor = new Map<String, String>();
        
        for(Schema.PicklistEntry opcaoDDI : Lead.DDICelular__c.getDescribe().getPicklistValues()) {
            ddisPorValor.put(opcaoDDI.getValue(), opcaoDDI.getLabel());
        }
        
        return ddisPorValor;
    }
    
    public static Map<String,String> obterMidias() {
        Map<String,String> midiasAtuaisPorValor = new Map<String,String>();
        
        for(Schema.PicklistEntry opcaoMidia : Lead.MidiaAtual__c.getDescribe().getPicklistValues()) {
            midiasAtuaisPorValor.put(opcaoMidia.getValue(), opcaoMidia.getLabel());
        }
        
        return midiasAtuaisPorValor;
    }
    
    public static String obterLeadsPorInformacoesConcierge(Map<String, String> formulario) {
        if (String.isEmpty(formulario.get('celular'))) formulario.put('ddiCel', null);
        if (String.isEmpty(formulario.get('telefone'))) formulario.put('ddiTel', null);
        
        List<LeadDTO> leadsDTO = new List<LeadDTO>();
        
        for(Lead lead : LeadSelector.obterLeadsPorInformacoesConcierge(getWhereParams(formulario))) {
            leadsDTO.add(new LeadDTO(lead));
        }
        
        return JSON.serialize(leadsDTO);
    }
    
    public static Id criarLead(Map<String, String> formulario) {
        String nome = formulario.get('nome');
        String ddiCel = formulario.get('ddiCel');
        String ddiTel = formulario.get('ddiTel');
        String dddCel = formulario.get('dddCel');
        String dddTel = formulario.get('dddTel');
        String celular = formulario.get('celular');
        String midia = formulario.get('midia');
        String email = formulario.get('email');
        String origem = formulario.get('origem');
        String canal = formulario.get('canal');
        String telefone = formulario.get('telefone');
        Id recordTypeId = formulario.get('recordType');
        
        if (String.isBlank(nome) || String.isBlank(recordTypeId)) {
            return null;
        }

        Boolean isLeadPj = RecordTypeSelector.getRecordTypeById(new Set<String>{'DeveloperName'}, recordTypeId).get(0).DeveloperName == 'PessoaJuridica';
                
        Lead lead = new Lead(
            RecordTypeId = recordTypeId,
            DDICelular__c = ddiCel,
            DDITelefone__c = ddiTel,
            DDDCelular__c = dddCel,
            MidiaAtual__c = midia,
            DDDTelefone__c = dddTel,
            Celular__c = celular,
            Phone = telefone,
            Email = email,
            LeadSource = origem,
            CanalAtendimento__c = canal,
            Status = 'New'
        );

        Map<String, String> nomes = separarNomes(nome);
        lead.FirstName = nomes.get('firstName');
        lead.LastName = nomes.get('lastName');
        
        if (isLeadPj) {
            lead.Company = formulario.get('empresa');
        }
        
        insert lead;
        return lead.Id;
    }
    
    private static String getWhereParams(Map<String,String> formulario) {
        Map<String, String> formToApiNameMap = new Map<String, String> {
            'email' => 'Email',
            'celular' => 'CelularFormatado__c',
            'telefone' => 'TelefoneFormatado__c',
            'ddiCel' => 'DDICelular__c',
            'ddiTel' => 'DDITelefone__c',
            'dddCel' => 'DDDCelular__c',
            'dddTel' => 'DDDTelefone__c',
            'empresa' => 'Company'
        };
        
        Set<String> fieldClauseSet = new Set<String>{
            '(Company LIKE \'%'+formulario.get('nome')+'%\' OR Name LIKE \'%'+formulario.get('nome')+'%\')'
        };
        
        formulario.remove('nome');
        
        for(String key : formulario.keySet()) {
            if(formulario.get(key) != null) {
                fieldClauseSet.add(formToApiNameMap.get(key) + ' LIKE \'%'+formulario.get(key)+'%\'');
            }
        }
        
        return String.join(fieldClauseSet, ' AND ');
    }
    
    private static Map<String, String> separarNomes(String nome) {
        return nome.contains(' ')
        ? new Map<String, String>{
            'firstName' => nome.left(nome.indexOf(' ')),
            'lastName' => nome.right(nome.length() - nome.indexOf(' ') - 1)
        }
        : new Map<String, String>{
            'firstName' => '',
            'lastName' => nome
        };
    }
}