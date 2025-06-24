@isTest
public class FetchEmpDetailsTest {
    @testSetup static void setup() {
        Employee__c empRecord = new Employee__c();
        empRecord.First_Name__c = 'Test Emplyee';
        empRecord.Email__c = 'test@test.com';
        empRecord.Connected_User__c = UserInfo.getUserId();
        insert empRecord;        
        
        Compensation__c compRecord = new Compensation__c();
        compRecord.Base_Pay__c = 'Hourly';
        compRecord.Basic_Salary__c = 12000;
        compRecord.Net_Salary__c = 57767;
        compRecord.Employee__c = empRecord.Id;
        insert compRecord;
        
        Attendance__c attRecord = new Attendance__c();  
        attRecord.In_Time__c = System.now();
        attRecord.Out_Time__c = System.now();
        attRecord.Employee__c = empRecord.Id;
        insert attRecord;
        
        Leave__c leaveRecord = new 	Leave__c();
        leaveRecord.Leave_Type__c = 'CL(Casual leave)';
        leaveRecord.Start_Date__c =  System.TODAY();
        leaveRecord.End_Date__c = System.TODAY()+3;
        leaveRecord.Employee__c = empRecord.Id;
        insert leaveRecord;
        
        /*Holiday holiRecord = new Holiday();
        holiRecord.Name = 'Holi';
        holiRecord.Description = 'Holi aayi';
        insert holiRecord;*/
    
    }
    
@isTest
    static void validateGetEmployeeDetail() {
		Employee__c empRec = [SELECT id,First_Name__c FROM Employee__c WHERE First_Name__c='Test Emplyee' LIMIT 1];
        System.AssertEquals(empRec.First_Name__c,'Test Emplyee');
		test.startTest();
        FetchEmpDetails.getEmployeeDetail('Employee', true);
        test.stopTest();
    }

@isTest
    static void validateGetCompensationDetail() {
        Compensation__c compRec = [SELECT id, Basic_Salary__c, Employee__c FROM Compensation__c ];
        //System.AssertEquals(compRec.Employee__c, );
         test.startTest();
        FetchEmpDetails.getCompensationDetail('Compensation', false);
         FetchEmpDetails.getCompensationDetail('Attendence', false);
         FetchEmpDetails.getCompensationDetail('Leave', false);
         FetchEmpDetails.getCompensationDetail('Holiday', false);
        test.stopTest();
        
         /*Holiday holidayRecord = [SELECT id, Name, Description FROM Holiday ];
        //System.AssertEquals(compRec.Employee__c, );
        test.startTest();
         FetchEmpDetails.getCompensationDetail('Holiday', false);*/
        
        //test.stopTest();
         
        //System.AssertEquals(compRec.Employee__c, );
       
    }    
}