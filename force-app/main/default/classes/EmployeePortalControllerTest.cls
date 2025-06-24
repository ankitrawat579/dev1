@isTest
public class EmployeePortalControllerTest {
    
    @testSetup 
    static void setup() {
        Employee__c empRecord = new Employee__c();
        empRecord.First_Name__c = 'Test Emplyee';
        empRecord.Email__c = 'test@test.com';
        empRecord.Performance_Flag__c = 'Green';
        empRecord.orgChartId__c = 123;
        empRecord.Connected_User__c = UserInfo.getUserId();
        
        insert empRecord;        
    }
    
    @isTest
    static void validateGetEmployeeDetail() {
		Employee__c empRecord = [SELECT Id, First_Name__c FROM Employee__c WHERE First_Name__c = 'Test Emplyee' LIMIT 1];
        System.AssertEquals(empRecord.First_Name__c, 'Test Emplyee');
		test.startTest();
            EmployeePortalController.getEmployeeDetail('Employee', true);
        test.stopTest();
    }
    
    @isTest
    static void getPerformanceFlagTest() {
        Employee__c empRecord = [SELECT Id, First_Name__c, Performance_Flag__c FROM Employee__c WHERE First_Name__c = 'Test Emplyee' LIMIT 1];
        System.AssertEquals(empRecord.Performance_Flag__c, 'Green');
        Test.startTest();
        EmployeePortalController.getPerformanceFlag();
        Test.stopTest();
    }
}