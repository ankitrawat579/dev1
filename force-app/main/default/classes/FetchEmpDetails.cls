public with sharing class FetchEmpDetails {
@AuraEnabled(cacheable = true)
public static DataWrapper getEmployeeDetail(String dataType, Boolean isSingle) {
    DataWrapper returnValue = new DataWrapper();
    Employee_Portal__mdt epMtd = Employee_Portal__mdt.getInstance(dataType); 
    if (dataType == 'Employee') {
        returnValue.records = getEmployeeData(epMtd, isSingle);
        returnValue.columns = epMtd.Columns__c.split(',');
        returnValue.isSingle = isSingle;
        returnValue.recordId = (String) returnValue.records[0].get('Id');
        returnValue.tableColumns = null;
        System.debug('Return value ' +returnValue.columns);
        System.debug('Return oinijhe ' +returnValue.isSingle);
        System.debug('Return msdjsabj ' +returnValue.records);
    } 
    return returnValue; 
}
@AuraEnabled(cacheable = true)
public static DataWrapper getCompensationDetail(String dataType, Boolean isSingle) {
    DataWrapper returnValue = new DataWrapper();
    Id userId = UserInfo.getUserId();
    List<ColumnWrapper> lstDataColumns = new List<ColumnWrapper>();
    List<SObject> lstDataTableData  = new List<SObject>();
    List<string> fieldAPINameList  = new List<string>();
    Employee_Portal__mdt epMtd = Employee_Portal__mdt.getInstance(dataType);
     if (dataType == 'Attendance') {
        String queryString = 'SELECT Id, ' + epMtd.Columns__c  + ' FROM Attendance__c WHERE Employee__r.Connected_User__c =:userId AND 	In_Time__c >= LAST_MONTH ORDER BY In_Time__c DESC';
        List<sObject> result = Database.query(queryString);
        if(epMtd.Columns__c != null) {
            fieldAPINameList = epMtd.Columns__c.split(',');
        }
        Map<String, String> fieldsMap = getComFieldsByobjectAPI('Attendance__c');
        ColumnWrapper datacolumns;
        for (String fieldApi : fieldAPINameList) {
            lstDataColumns.add(new ColumnWrapper(fieldApi, fieldsMap.get(fieldApi)));
        }
        returnValue.tableColumns = lstDataColumns;
        returnValue.records    = result;
        returnValue.isSingle = isSingle;
    }  else if (dataType == 'Leave') {
        String queryString = 'SELECT Id, ' + epMtd.Columns__c  + ' FROM Leave__c WHERE Employee__r.Connected_User__c =:userId ';
        queryString += 'AND Start_Date__c >= LAST_QUARTER ORDER BY Start_Date__c DESC';
        List<sObject> result = Database.query(queryString);
        if(epMtd.Columns__c != null) {
            fieldAPINameList = epMtd.Columns__c.split(',');
        }
        Map<String, String> fieldsMap = getComFieldsByobjectAPI('Leave__c');
        ColumnWrapper datacolumns;
        for (String fieldApi : fieldAPINameList) {
            lstDataColumns.add(new ColumnWrapper(fieldApi, fieldsMap.get(fieldApi)));
        }
        returnValue.tableColumns = lstDataColumns;
        returnValue.records    = result;
        returnValue.isSingle = isSingle;
    } else if (dataType == 'Compensation') {
        String queryString = 'SELECT Id, ' + epMtd.Columns__c  + ' FROM Compensation__c WHERE Employee__r.Connected_User__c =:userId ';
        queryString += 'ORDER BY Effective_From__c DESC';
        List<sObject> result = Database.query(queryString);
        if(epMtd.Columns__c != null){
            fieldAPINameList = epMtd.Columns__c.split(',');
        }  
        Map<String, String> fieldsMap = getComFieldsByobjectAPI('Compensation__c');
        ColumnWrapper datacolumns;
        for (String fieldApi : fieldAPINameList) {
            lstDataColumns.add(new ColumnWrapper(fieldApi, fieldsMap.get(fieldApi)));
        }
        returnValue.tableColumns = lstDataColumns;
        returnValue.records    = result;
        returnValue.isSingle = isSingle;
        } 
        else if (dataType == 'Holiday') {
        String queryString = 'SELECT Id, ' + epMtd.Columns__c  + ' FROM Holiday  WHERE ActivityDate >= TODAY ORDER BY ActivityDate LIMIT 3 ';
        List<sObject> result = Database.query(queryString);
        if(epMtd.Columns__c != null){
            fieldAPINameList = epMtd.Columns__c.split(',');
        }  
        Map<String, String> fieldsMap = getComFieldsByobjectAPI('Holiday');
        ColumnWrapper datacolumns;
        for (String fieldApi : fieldAPINameList) {
            lstDataColumns.add(new ColumnWrapper(fieldApi, fieldsMap.get(fieldApi)));
        }
        returnValue.tableColumns = lstDataColumns;
        returnValue.records    = result;
        returnValue.isSingle = isSingle;
        } else if (dataType == 'Project') {
            String queryString = 'SELECT Id, ' + epMtd.Columns__c  + ' FROM Employee_Engagement__c WHERE Employee__r.Connected_User__c =:userId AND (End_Date__c = null OR End_Date__c >= LAST_MONTH) ORDER BY Start_Date__c DESC ';
            List<sObject> result = Database.query(queryString);
            if(epMtd.Columns__c != null){
                fieldAPINameList = epMtd.Columns__c.split(',');
            }  
            Map<String, String> fieldsMap = getComFieldsByobjectAPI('Employee_Engagement__c');
            ColumnWrapper datacolumns;
            for (String fieldApi : fieldAPINameList) {
                lstDataColumns.add(new ColumnWrapper(fieldApi, fieldsMap.get(fieldApi)));
            }
            returnValue.tableColumns = lstDataColumns;
            returnValue.records    = result;
            returnValue.isSingle = isSingle;
        }
    return returnValue;
}

public static Map<String, String> getComFieldsByobjectAPI(String objAPI){
    Map<String, String> objFields = new Map<String, String>();
    Map <String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objAPI).getDescribe().fields.getMap();
    for(Schema.SObjectField singlefield : fieldsMap.Values()) {
        String apiName = singlefield.getDescribe().getLocalName();
        String name = singlefield.getDescribe().getLabel();
        objFields.put(apiName, name);
    }
    System.debug('Comp objFields = '+objFields);
    return objFields;
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
    @AuraEnabled public List<ColumnWrapper> tableColumns;
    @AuraEnabled public String recordId;
}

public class ColumnWrapper {
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String fieldName {get;set;}
    
    public ColumnWrapper(String fieldName, String label) {
        this.label     = label;
        this.fieldName = fieldName;         
    }
}
}