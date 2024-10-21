public with sharing class TaskDA {
    public static List<Task> getContactTasksByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND Subject <> \'Reiteração\'',
                new String[]{String.join(new List<String>(fields), ',')}
             )
        );
    }

    public static List<Task> getContactTasksByWhoIdAndStatus(Set<String> fields, Set<Id> idLeads, String status){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND Status = :status AND Subject <> \'Reiteração\'',
                new String[]{String.join(new List<String>(fields), ',')}
             )
        );
    }

    public static List<Task> getTasksByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads ',
                new String[]{String.join(new List<String>(fields), ',')}
             )
        );
    }

    public static List<Task> getTasksReiteracaoNaoIniciadoByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND (Subject = \'Reiteração\') AND (Status = \'Not Started\') ',
                new String[]{String.join(new List<String>(fields), ',')}
            )
        );
    }
    
    public static List<Task> getTasksReiteracaoByWhoId(Set<String> fields, Set<Id> idLeads){
        return Database.query(
            String.format(
                'SELECT {0} FROM Task WHERE WhoId IN :idLeads AND (Subject = \'Reiteração\')',
                new String[]{String.join(new List<String>(fields), ',')}
            )
        );
    }

    public static void insertTasks(List<Task> tasks) {
        if(tasks == null || tasks.isEmpty()) return;
        insert tasks;
    }
}