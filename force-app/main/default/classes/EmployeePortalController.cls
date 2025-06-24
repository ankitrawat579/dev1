public with sharing class EmployeePortalController {

    @AuraEnabled(cacheable = true)
    public static DataWrapper getEmployeeDetail(String dataType, Boolean isSingle) {
        DataWrapper returnValue = new DataWrapper();
        Employee_Portal__mdt epMtd = Employee_Portal__mdt.getInstance(dataType);
        if (dataType == 'Employee') {
            returnValue.records = getEmployeeData(epMtd, isSingle);
            returnValue.columns = epMtd.Columns__c.split(',');
            returnValue.isSingle = isSingle;
            returnValue.recordId = (String) returnValue.records[0].get('Id');
        }
        return returnValue;
    }
    
    private static List<SObject> getEmployeeData(Employee_Portal__mdt epMtd, Boolean isSingle) {
        Id userId = UserInfo.getUserId();
        String queryString = 'SELECT Id, ' + epMtd.Columns__c + ' FROM Employee__c WHERE Connected_User__c   =: userId';
        if (isSingle) {
            queryString += ' LIMIT 1';   
        }
        return Database.query(queryString);
    }
    
    public class DataWrapper {
        
        @AuraEnabled public List<SObject> records;
        @AuraEnabled public Boolean isSingle;
        @AuraEnabled public List<String> columns;
        @AuraEnabled public String recordId;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Employee__c> getPerformanceFlag() {
        Id userId = UserInfo.getUserId();
        List<Employee__c> employeeList = [SELECT  Performance_Flag__c, Color_Code__c FROM Employee__c WHERE Connected_User__c   =: userId LIMIT 1];
        return employeeList ;
    }
}