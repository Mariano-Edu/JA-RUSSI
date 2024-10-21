public with sharing class EmpreendimentoTriggerHandler extends TriggerHandler {

    // Sobrescrevendo o método beforeInsert para lidar com a lógica antes de inserir registros
    public override void beforeInsert() {
        List<String> ceps = new List<String>();
        for (Empreendimento__c emp : (List<Empreendimento__c>) Trigger.new) {
            if (emp.CEP__c != null) {
                ceps.add(emp.CEP__c);
            }
        }

        // Lógica para verificar se não é um contexto futuro ou em lote
        if (!ceps.isEmpty() && !System.isFuture() && !System.isBatch()) {
            for (String cep : ceps) {
                EmpreendimentoHelper.getCEPDataAsyncFuture(cep);
            }
        }
    }

    // Sobrescrevendo o método beforeUpdate para lidar com a lógica antes de atualizar registros
    public override void beforeUpdate() {
        List<String> ceps = new List<String>();
        for (Empreendimento__c emp : (List<Empreendimento__c>) Trigger.new) {
            Empreendimento__c oldEmp = (Empreendimento__c) Trigger.oldMap.get(emp.Id);
            if (emp.CEP__c != null && emp.CEP__c != oldEmp.CEP__c) {
                ceps.add(emp.CEP__c);
            }
        }

        // Lógica para verificar se não é um contexto futuro ou em lote
        if (!ceps.isEmpty() && !System.isFuture() && !System.isBatch()) {
            for (String cep : ceps) {
                EmpreendimentoHelper.getCEPDataAsyncFuture(cep);
            }
        }
    }
}