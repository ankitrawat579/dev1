public with sharing class EmployeePortalDataController {
    
    /** 
     * Used to get record data
     * @param dataType is type of Record/Object (Object)
     * @param isSingle is the flag which will tell us wether record is single or list
     * @return DataWrapper is the combined data to show on UI
    */
    @AuraEnabled(cacheable = true)
    public static DataWrapper getData(String dataType, Boolean isSingle, String orderBy, String orderType, Integer limits) {
        DataWrapper returnValue = new DataWrapper();
        System.debug('returnValue ==' +returnValue);
        returnValue.isError = false;
        if(isSingle){
            List<String>col= getFieldsByFieldSet(dataType, 'Employee_Portal_FieldSet');
            if(!col.isEmpty()){
                returnValue.columns=col;
                List<SObject> relatedRecords = getRelatedData(dataType, returnValue.columns, isSingle, orderBy, orderType, limits);
                System.debug('relatedRecords ==' +relatedRecords);
              
                if(!relatedRecords.isEmpty()){
                    returnValue.records=relatedRecords;
                    System.debug('returnValue.records ==' +returnValue.records);
                }else{
                    returnValue.isError=true;
                    returnValue.errorMessage='No records available.';
                }
            
                returnValue.isSingle = isSingle;
                returnValue.tableColumns = getColumnWrappers(dataType,'Employee_Portal_FieldSet'); 
                System.debug('returnValue.tableColumns ==' +returnValue.tableColumns);
            }else{
                returnValue.isError=true;
                returnValue.errorMessage='No object available.';
            }
            returnValue.isSingle = isSingle;
            returnValue.recordId = (String) returnValue.records[0].get('Id');
            returnValue.tableColumns = null;
        } else{
            if(dataType!='Holiday'){
                List<String>col= getFieldsByFieldSet(dataType, 'Employee_Portal_FieldSet');
                System.debug('col ==' +col);
                if(!col.isEmpty()){
                    returnValue.columns=col;
                    List<SObject> relatedRecords = getRelatedData(dataType, returnValue.columns, isSingle, orderBy, orderType, limits);
                    System.debug('relatedRecords ==' +relatedRecords);
                 
                    if(!relatedRecords.isEmpty()){
                        returnValue.records=relatedRecords;
                        
                    }else{
                        returnValue.isError=true;
                        returnValue.errorMessage='No records available.';
                    } 
                    returnValue.isSingle = isSingle;
                    returnValue.tableColumns = getColumnWrappers(dataType,'Employee_Portal_FieldSet'); 
                }else{
                    returnValue.isError=true;
                    returnValue.errorMessage='No object available.';
                }
           
            }
            else
            {
                List<SObject> relatedRecords =getHolidayData(dataType, orderBy, orderType, limits);
                if(!relatedRecords.isEmpty()){
                    returnValue.records=relatedRecords;
                }else{
                    returnValue.isError=true;
                    returnValue.errorMessage='No records available.';
                }
                returnValue.isSingle=isSingle;
            }
        }
        return returnValue; 
    }


    public static List<sobject> getHolidayData(String dataType, String orderBy, String orderType, Integer limits){
        String queryString = 'SELECT Name, ActivityDate FROM Holiday  WHERE ActivityDate >= TODAY';
        if(orderBy != null) {
                queryString += ' ORDER BY '   +orderBy+  ' '  + orderType ;
            }
            
            if(limits != null && limits > 0) {
                queryString += ' LIMIT ' + String.valueOf(limits);
            }
        System.debug('QUERY '  +queryString);
        return Database.query(queryString);
    }
    
    /** 
     * Used to get related data of fields of the fieldset
     * @param objectApi is name of Object which is provided at run time 
     * @param fields is the list of fields given by getFieldsByFieldSet method 
     * @param isSingle is the flag which will tell us whether record is single or list
     * @return Database.query(queryString) is the dynamic query 
    */
    private static List<SObject> getRelatedData(String objectApi, List<String> fields, Boolean isSingle, String orderBy, String orderType, Integer limits) {
        Id userId = UserInfo.getUserId();
        System.debug('userId ==' +userId);
        String queryString;
        if (isSingle) {
            queryString = 'SELECT ' + String.join(fields,',') + ' FROM ' + objectApi + ' WHERE Connected_User__c   =: userId LIMIT 1';
            System.debug('queryString ==' +queryString);
        } else {
            queryString = 'SELECT ' + String.join(fields,',') + ' FROM ' + objectApi + ' WHERE Employee__r.Connected_User__c   =: userId';
            if(orderBy != null) {
                queryString += ' ORDER BY '   +orderBy+  ' '  + orderType ;
            }
            
            if(limits != null && limits > 0) {
                queryString += ' LIMIT ' + String.valueOf(limits);
            }
        }
        return Database.query(queryString);
    }
    
    /** 
     * Used to get fields(api name) from fieldset
     * @param objectApi is name of Object which is provided at run time 
     * @param fieldSetName is the api name of the fieldset
     * @return List<String> is returning fields(api name)
    */
    public static List<String> getFieldsByFieldSet(String objectApi, String fieldSetName) {
        List<String> returnValue = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApi);
        Schema.DescribeSObjectResult dor = objType.getDescribe();
        Schema.FieldSet fieldSetObj = dor.FieldSets.getMap().get(fieldSetName); 
        for (Schema.FieldSetMember fieldSet : fieldSetObj.getFields()) {
            returnValue.add(fieldSet.getFieldPath()); 
        }
        return returnValue;
    }
    
    /** 
     * Used to get fields(api name,label) from fieldset
     * @param objectApi is name of Object which is provided at run time 
     * @param fieldSetName is the api name of the fieldset
     * @return List<ColumnWrapper> is returning field's api and label 
    */
    private static List<ColumnWrapper> getColumnWrappers(String objectApi, String fieldSetName) {
        List<ColumnWrapper> returnValue = new List<ColumnWrapper>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApi);
        Schema.DescribeSObjectResult dor = objType.getDescribe();
        Schema.FieldSet fieldSetObj = dor.FieldSets.getMap().get(fieldSetName); 
        for (Schema.FieldSetMember fieldSet : fieldSetObj.getFields()) {
            returnValue.add(new ColumnWrapper(fieldSet.getFieldPath(), fieldSet.getlabel())); 
        }
        return returnValue;
    }
    
    /**
    * @class Datawrapper wraps several datatypes (List,Boolean,String)
    */
    public class DataWrapper {
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public List<SObject> records;
        @AuraEnabled public Boolean isSingle;
        @AuraEnabled public List<String> columns;
        @AuraEnabled public List<ColumnWrapper> tableColumns;
        @AuraEnabled public String recordId;
        
    }
	
    /**
    * @class Columnwrapper wraps several datatypes(constructor)
    */
    public class ColumnWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        
        public ColumnWrapper(String fieldName, String label) {
            this.label     = label;
            this.fieldName = fieldName;         
        }
    }
}