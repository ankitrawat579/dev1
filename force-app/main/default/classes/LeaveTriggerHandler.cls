public class LeaveTriggerHandler {
    public static void handleInsert(List<Leave__c> leaves) {
        Map<Id,decimal> empIdToLeaveCountMap = LeaveTriggerHelper.getEmpLeaveCount(leaves);
        LeaveTriggerHelper.EmployeeUpdate(empIdToLeaveCountMap,true);
    }
     
    public static void handleDelete(List<Leave__c> leaves) {
       Map<Id,decimal> empIdToLeaveCountMap = LeaveTriggerHelper.getEmpLeaveCount(leaves);
        LeaveTriggerHelper.EmployeeUpdate(empIdToLeaveCountMap,false);
    }
    
    public static void handleUpdate(List<Leave__c> leaves, Map<Id,Leave__c> oldMap) {
        LeaveTriggerHelper.handleUpdateRecord(leaves, oldMap);
    }
}