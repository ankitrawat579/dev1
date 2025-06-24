public class EmployeeHierarchyController {
    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getEmployeeDetails() {
        return [SELECT orgChartId__c, orgChartParentId__c, Name , Designation__c
        FROM Employee__c 
        where Active__c =true];
    }
}