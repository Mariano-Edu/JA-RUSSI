public class UserController {

    @AuraEnabled(cacheable = true)
    public static Map<Id,User> getUsersById(){
        return new Map<Id,User>([SELECT Id, Name FROM User]);
    }

}