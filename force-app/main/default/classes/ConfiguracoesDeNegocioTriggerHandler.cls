public with sharing class ConfiguracoesDeNegocioTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        ConfiguracoesDeNegocioHelper.getInstance().validaDuplicado(Trigger.new);
    }
    public override void beforeUpdate(){
        ConfiguracoesDeNegocioHelper.getInstance().validaDuplicado(Trigger.new);
    }
   
}