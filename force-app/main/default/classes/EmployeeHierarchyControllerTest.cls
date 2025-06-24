@isTest
public class EmployeeHierarchyControllerTest {
 	@isTest
    public static void GetEmployeeDetails(){
        list<Employee__c> Emplist = New List<Employee__c>();
        
        
            Employee__c Emp = New Employee__c();
            Emp.Name = 'Nidhi';
            Emp.Bank_Account_Number__c = '123456789000';
            Emp.IFSC_Code__c = '0000SBI0908';
            Emp.orgChartId__c = 4;
            Emp.orgChartParentId__c = 5;
            Emp.Active__c = True;
           	Emplist.Add(Emp);
        
        
        Test.StartTest();
        Insert Emplist;
        Test.StopTest();
        
        list<Employee__c> UpdatedEmplist= [Select Id,Name,orgChartId__c,orgChartParentId__c
                                           from Employee__c where Id =:Emplist[0].Id];
        
        system.assertEquals(4,UpdatedEmplist[0].orgChartId__c);
        system.assertEquals(5,UpdatedEmplist[0].orgChartParentId__c);
        EmployeeHierarchyController.getEmployeeDetails();
        
    }

}