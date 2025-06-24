@isTest
public class EmployeePortalDataControllerTest {
    
    @testSetup static void setup() {
        Employee__c empRecord = new Employee__c(
            Employee_Code__c='E-07',
            First_Name__c = 'Test Employee',
            Last_Name__c='Test',
            Phone__c= '9876543210',
            Email__c = 'test@test.com',
            Connected_User__c = UserInfo.getUserId()
        );
        insert empRecord; 
        
        list<Compensation__c> lstCompensation = new list<Compensation__c>();
        Compensation__c compRecord = new Compensation__c();
        compRecord.Net_Salary__c = 12000;
        compRecord.Base_Pay__c = 'Hourly';
        compRecord.HRA__c = 2000;
        compRecord.DA__c = 2000;
        compRecord.Employee__c = empRecord.Id;
        lstCompensation.add(compRecord);
        insert lstCompensation;
        
        Attendance__c attRecord = new Attendance__c(  
            In_Time__c = System.now(),
            Out_Time__c = System.now(),
            Employee__c = empRecord.Id
        );
        insert attRecord;
        
        Leave__c leaveRecord = new Leave__c(
            Leave_Type__c = 'CL(Casual leave)',
            Start_Date__c =  System.TODAY(),
            End_Date__c = System.TODAY()+3,
            Employee__c = empRecord.Id
        );
        insert leaveRecord;
    }  
    
    @isTest
    static void validateGetDataWhenSingleIsTrue() {
        test.startTest();
        EmployeePortalDataController.DataWrapper empData = EmployeePortalDataController.getData('Employee__c', true, null, null, 1);
        if (empData != null && empData.records != null) {
            System.assertEquals(1, empData.records.size());
        } else {
            System.assert(false, 'empData or empData.records is null');
        }
        test.stopTest();
    }
    
    @isTest
    static void validateGetDataWhenSingleIsFalse() {
        test.startTest();
        EmployeePortalDataController.DataWrapper attData = EmployeePortalDataController.getData('Attendance__c', false, 'In_Time__c', 'ASC', 2);
        if (attData != null && attData.records != null) {
            System.assertEquals(1, attData.records.size());
        } else {
            System.assert(false, 'attData or attData.records is null');
        }
        
        EmployeePortalDataController.DataWrapper holidayData = EmployeePortalDataController.getData('Holiday', false, 'ActivityDate', 'DESC', 3);
        if (holidayData != null && holidayData.records != null) {
            System.assertEquals(3, holidayData.records.size());
        } else {
            System.assert(false, 'holidayData or holidayData.records is null');
        }
        test.stopTest();
    }
}