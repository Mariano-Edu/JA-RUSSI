({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        let loading =  true;
        var action = component.get('c.gerarMinutaByContract');
        action.setParams({ contractId : recordId });
        action.setCallback(this, function(response) {
            loading = false;

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Documento gerado",
                "message": "Favor verificar a lista de anexos.",
                "type" : "success"
            });
            toastEvent.fire();

            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})