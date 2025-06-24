public class LeaveTriggerHelper {
    
    public static void handleUpdateRecord(List<Leave__c> leaves, Map<Id,Leave__c> oldMap) {
        Map<Id,decimal> empIdToLeaveCountMap = getEmpLeaveCount(leaves);
        List<Employee__c> empUpdateList = New List<Employee__c>();
        for (Leave__c leave : leaves) {
            if (empIdToLeaveCountMap.get(leave.Employee__c) != null && (leave.End_Date__c != oldMap.get(leave.Id).End_Date__c || leave.Start_Date__c != oldMap.get(leave.Id).Start_Date__c)) {
                Decimal noOfLeaves = leave.Start_Date__c.daysBetween(leave.End_Date__c) + 1;
                Decimal noOfLeaves2 = oldMap.get(leave.Id).Start_Date__c.daysBetween(oldMap.get(leave.Id).End_Date__c) + 1;
                For (Employee__c empRecord : [SELECT Id, Leave_Balance__c FROM Employee__c WHERE Id IN:empIdToLeaveCountMap.keySet()]){
                   empRecord.Leave_Balance__c = (empRecord.Leave_Balance__c + noOfLeaves2 ) - noOfLeaves; 
                   empUpdateList.add(empRecord);                        
                }
            }
        }
        if (!empUpdateList.isEmpty()){
            update empUpdateList;
        }
    }
    
    public static Map<Id,decimal> getEmpLeaveCount(List<Leave__c> leaves) {
        Map<Id,decimal> empIdToLeaveCountMap = new Map<Id,decimal>();
        for (Leave__c leave : leaves) {
            Decimal noOfLeaves = leave.Start_Date__c.daysBetween(leave.End_Date__c) + 1;
            if (empIdToLeaveCountMap.get(leave.Employee__c) != null) {
                if (leave.Leave_Type__c == 'HL(Half-day leave)') {
                    empIdToLeaveCountMap.put(leave.Employee__c, empIdToLeaveCountMap.get(leave.Employee__c) + noOfLeaves/2);
                } 
                else {
                    empIdToLeaveCountMap.put(leave.Employee__c, empIdToLeaveCountMap.get(leave.Employee__c) + noOfLeaves); 
                }
            } 
            else {
                if (leave.Leave_Type__c == 'HL(Half-day leave)') {
                    empIdToLeaveCountMap.put(leave.Employee__c, noOfLeaves/2);
                } else {
                    empIdToLeaveCountMap.put(leave.Employee__c, noOfLeaves);
                }
            }   
        }
        return empIdToLeaveCountMap;
    }
    
    public static void EmployeeUpdate(Map<Id,decimal> empIdToLeaveCountMap, Boolean isAddition) {
        List<Employee__c> empUpdateList = New List<Employee__c>();
        For (Employee__c empRecord : [SELECT Id, Leave_Balance__c FROM Employee__c WHERE Id IN:empIdToLeaveCountMap.keySet()]){
            if(isAddition){
                empUpdateList.add(new Employee__c(Id=empRecord.Id, Leave_Balance__c=empRecord.Leave_Balance__c - empIdToLeaveCountMap.get(empRecord.Id))); 
            }
            else {
                empUpdateList.add(new Employee__c(Id=empRecord.Id, Leave_Balance__c=empRecord.Leave_Balance__c + empIdToLeaveCountMap.get(empRecord.Id))); 
            }
        }
        if (!empUpdateList.isEmpty()){
            update empUpdateList;
        }
        
    }
    
}