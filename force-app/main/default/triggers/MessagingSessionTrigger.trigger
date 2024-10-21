trigger MessagingSessionTrigger on MessagingSession (before insert, after insert, before update, after update) {
	(new MessagingSessionTriggerHandler()).run();
}