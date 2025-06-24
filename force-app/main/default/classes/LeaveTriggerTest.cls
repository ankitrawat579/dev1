@isTest
public class LeaveTriggerTest {
    static testMethod void testInsert() {
        
        Employee__c empRecord = new Employee__c(Leave_Balance__c = 20);
       	insert empRecord;
       
        Leave__c leaveRecord = new Leave__c(Employee__c = empRecord.Id, Start_Date__c = system.today(),
                                            End_Date__c = system.today()+2 , Leave_Type__c = 'HL(Half-day leave)');
        insert leaveRecord;
        
        Leave__c leaveRecord2 = new Leave__c(Employee__c = empRecord.Id, Start_Date__c = system.today(),
                                            End_Date__c = system.today()+2 , Leave_Type__c = 'CL(Casual leave)');
        insert leaveRecord2;
        
        Leave__c insertedRecord = [SELECT Id FROM Leave__c WHERE Id = :leaveRecord.Id LIMIT 1];
        System.assertNotEquals(null, insertedRecord);
        
        Leave__c insertedRecord2 = [SELECT Id FROM Leave__c WHERE Id = :leaveRecord2.Id LIMIT 1];
        
        delete insertedRecord;
        delete insertedRecord2;
        
    }

    static testMethod void testUpdate() {
        Employee__c empRecord = new Employee__c(Leave_Balance__c = 20);
       	insert empRecord;
        Leave__c leaveRecord = new Leave__c(Employee__c = empRecord.Id, Start_Date__c = system.today(),
                                            End_Date__c = system.today()+2 , Leave_Type__c = 'HL(Half-day leave)');
        insert leaveRecord;

        leaveRecord.Start_Date__c = system.today()+3;
        update leaveRecord;
        Leave__c updatedRecord = [SELECT Id,Start_Date__c FROM Leave__c WHERE Id = :leaveRecord.Id LIMIT 1];
        System.assertEquals(system.today()+3, updatedRecord.Start_Date__c);
        delete updatedRecord;
    }

    static testMethod void testDelete() {
        
        Employee__c empRecord = new Employee__c(Leave_Balance__c = 20);
       	insert empRecord;
        Leave__c leaveRecord = new Leave__c(Employee__c = empRecord.Id, Start_Date__c = system.today(),
                                            End_Date__c = system.today()+2 , Leave_Type__c = 'HL(Half-day leave)');
        insert leaveRecord;

        delete leaveRecord;

        List<Leave__c> deletedRecords = [SELECT Id FROM Leave__c WHERE Id = :leaveRecord.Id];
        System.assertEquals(0, deletedRecords.size());
    }
}