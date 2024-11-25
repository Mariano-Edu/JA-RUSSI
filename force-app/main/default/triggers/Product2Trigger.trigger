trigger Product2Trigger on Product2 (after insert) {
    new Product2TriggerHandler().run();
}