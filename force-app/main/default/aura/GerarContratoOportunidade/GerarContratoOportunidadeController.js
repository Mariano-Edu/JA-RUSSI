({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        let loading =  true;
        var action = component.get('c.generateContract');
        action.setParams({ recordId : recordId });
        action.setCallback(this, function(response) {
            loading = false;

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Contrato gerado",
                "message": "Favor verificar o campo Contrato.",
                "type" : "success"
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();

            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})