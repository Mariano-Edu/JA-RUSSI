public with sharing class LeadVencidoSchedule implements Schedulable {
    
    public Boolean runOnlyOnce;
    public Integer minutes;
    
    public LeadVencidoSchedule()
    {
        this.runOnlyOnce = false;
    }
    
    public LeadVencidoSchedule(Integer minutes, Boolean runOnlyOnce)
    {
        this.minutes = minutes;
        this.runOnlyOnce = runOnlyOnce;
    }

    public void reeschedule()
    {
        Datetime nextMinute = System.now().addMinutes(this.minutes);

        Integer year = nextMinute.year();
        Integer month = nextMinute.month();
        Integer day = nextMinute.day();
        Integer hour = nextMinute.hour();
        Integer min = nextMinute.minute(); 
        Integer ss = nextMinute.second();
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        
        LeadVencidoSchedule scheduler = new LeadVencidoSchedule(this.minutes, this.runOnlyOnce); 
        
        String jobId = '';
        
        if(this.runOnlyOnce)
        {
            System.schedule('LeadVencidoSchedule - Started: ' + String.valueOf(Datetime.now()), nextFireTime, scheduler);
        }
        else
        {
            System.schedule('LeadVencidoSchedule AUTOMATIC - it runs every '+this.minutes+' minute(s) :'+nextFireTime+':', nextFireTime, scheduler);            
        }
    }

    public void execute(SchedulableContext sc)
    {
        //Abort the current job
        Id jobId = sc.getTriggerId(); 
    
        //runOnlyOnce => true = executa uma vez
        //runOnlyOnce => false = reagenda a próxima execução

        if(!this.runOnlyOnce)
        {
            System.abortJob(jobId); 
            reeschedule(); 
        } 
            
        run();
    }
    
    public void run()
    {
        LeadVencidoBatch ranking = new LeadVencidoBatch();
        Database.executeBatch(ranking);
        Id batchId = Database.executeBatch(ranking, 200);
        system.debug('BATCH ID : ' + batchId);
    }
    
    public static void startJob(Integer minutes, Boolean runOnlyOnce)
    {
       new LeadVencidoSchedule(minutes, runOnlyOnce).reeschedule();
    }        
    
}