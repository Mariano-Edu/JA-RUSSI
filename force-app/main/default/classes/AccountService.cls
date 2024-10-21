public class AccountService {
    static Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    static Schema.SObjectType myobjectSchema = schemaMap.get('Account');
    static Map<String, Schema.SObjectField> fieldMap = myobjectSchema.getDescribe().fields.getMap();

    public static Map<String, Account> obterInfoContaPorAnaliseCredito(Id idAnaliseCredito) {
        AnaliseDeCredito__c analiseCredito = AnaliseCreditoSelector.obterAnaliseCreditoPorId(idAnaliseCredito);

        List<Comprador__c> compradores =  CompradorSelector.obterCompradoresPorOportunidade(analiseCredito.Oportunidade__c);

        Map<String, Account> infoConta = new Map<String, Account>();
        
        for(Comprador__c comprador : compradores) {
            infoConta.put(comprador.Conta__r.Name, AccountSelector.obterInfoContaPorId(comprador.Conta__r.Id));
        }

        return infoConta;
    }

    public static void atualizarValoresConta(Map<String, String> camposValores, Id idConta){
        Account conta = AccountSelector.obterContaPorId(idConta);
        
        for(String campo : camposValores.keySet()) {
            switch on fieldMap.get(campo).getDescribe().getType() {
                when DOUBLE {
                    conta.put(campo, Decimal.valueOf((String) camposValores.get(campo)));
                }
                when STRING, PHONE, PICKLIST, ID, ADDRESS, URL {
                    conta.put(campo, (String) camposValores.get(campo));
                }
                when DATE {
                    conta.put(campo, Date.valueOf((String) camposValores.get(campo)));
                }
                when BOOLEAN {
                    conta.put(campo, Boolean.valueOf((String) camposValores.get(campo)));
                }
                when INTEGER {
                    conta.put(campo, Integer.valueOf((String) camposValores.get(campo)));
                }
                when DATETIME {
                    conta.put(campo, Datetime.valueOf((String) camposValores.get(campo)));
                }
            }
        }

        update conta;
    }
}