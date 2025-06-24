public with sharing class TrainingController {
    
    @AuraEnabled
    public static List<Training_Schedule__c> getUpcomingTrainings() {
        try {
            return [
                SELECT Id, Name, Schedule_Time__c, Subtopics__c, Topic__c, Trainer_Name__c
                FROM Training_Schedule__c
                WHERE Schedule_Time__c >= TODAY
                 AND Id NOT IN (
                    SELECT Training_Schedule__c 
                    FROM Employee_Training__c 
                    WHERE Employee__c =: getCurrentUserEmployeeId()
                ) ORDER BY Schedule_Time__c LIMIT 10
            ];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<Training_Schedule__c> getEnrolledTrainings() {
        try {
            return [
                SELECT Id, Name, Schedule_Time__c, Subtopics__c, Topic__c, Trainer_Name__c
                FROM Training_Schedule__c
                WHERE Schedule_Time__c >= TODAY
                AND Id IN (
                    SELECT Training_Schedule__c 
                    FROM Employee_Training__c 
                    WHERE Employee__c =: getCurrentUserEmployeeId()
                ) ORDER BY Schedule_Time__c LIMIT 10
            ];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void enroll(Id trainingId) {
        try {
            insert new Employee_Training__c(
                Employee__c = getCurrentUserEmployeeId(), 
                Training_Schedule__c = trainingId
            );
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void assignToMe(Id trainingId) {
        try {
            update new Training_Schedule__c(
                Id = trainingId,
                Trainer__c = getCurrentUserEmployeeId()
            );
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void decline(Id trainingId) {
        try {
            delete [
                SELECT Id 
                FROM Employee_Training__c 
                WHERE Employee__c =: getCurrentUserEmployeeId()
                AND Training_Schedule__c =: trainingId
            ];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Id getCurrentUserEmployeeId() {
        return [SELECT Id FROM Employee__c WHERE Connected_User__c =: UserInfo.getUserId() LIMIT 1].Id;
    }
}