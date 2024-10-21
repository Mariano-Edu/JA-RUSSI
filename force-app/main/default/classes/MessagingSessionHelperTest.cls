@isTest
private class MessagingSessionHelperTest {
    @TestSetup
    static void makeData() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            MessagingChannel channel = new MessagingChannel(
                MessageType = 'WhatsApp',
                DeveloperName = 'CanalTeste',
                IsActive = true,
                MasterLabel = 'Master',
                MessagingPlatformKey = 'test'
            );
            insert channel;

            MessagingEndUser objMsgUser = new MessagingEndUser();
            objMsgUser.Name = 'Messaging User';
            objMsgUser.MessagingChannelId = channel.Id;
            objMsgUser.MessageType = 'EmbeddedMessaging';
            objMsgUser.MessagingPlatformKey = 'TestChannel';
            insert objMsgUser;
    
            insert new MessagingSession(
                Status = 'Active',
                MessagingChannelId = channel.Id,
                MessagingEndUserId = objMsgUser.Id
            );
        }
    }

    @isTest
    private static void handleSessionLeadsInsertTest() {
        Id channelId = [SELECT Id FROM MessagingChannel LIMIT 1].Id;
        List<MessagingSession> sessions = [SELECT Id, MessagingEndUserId, LeadId, OwnerId FROM MessagingSession];
        
        Test.startTest();
        MessagingSessionHelper.handleSessionLeads(sessions);
        Test.stopTest();

        MessagingSession updatedSession = [SELECT LeadId FROM MessagingSession LIMIT 1];

        Assert.isNotNull(updatedSession.LeadId);
    }
}