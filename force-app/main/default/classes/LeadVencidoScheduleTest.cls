@isTest
public class LeadVencidoScheduleTest {
    
    @isTest
    static void testScheduleJob() {
        Test.startTest();
        LeadVencidoSchedule.startJob(1, false);
        Test.stopTest();
        
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'LeadVencidoSchedule%'];
        System.assert(!jobs.isEmpty());
    }

}