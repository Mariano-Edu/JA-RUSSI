trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert, before update, before delete, after insert, after delete) {
    new OpportunityTeamMemberTriggerHandler().run();

}