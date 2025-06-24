@isTest
public  class TrainingControllerTest {

@testSetup static void getTrainingRecords()
{

    Employee__c emp =new Employee__c();
    emp.First_Name__c='XYZ';
    emp.Email__c='test@gmail.com';
    emp.Connected_User__c = UserInfo.getUserId();
    insert emp;

    Employee__c emp1 =new Employee__c();
    emp1.First_Name__c='XYZ';
    emp1.Email__c='test@gmail.com';
    insert emp1;

    Training_Schedule__c trainingSchedule = new  Training_Schedule__c ();
    trainingSchedule.Schedule_Time__c= date.today()+5;
    trainingSchedule.Subtopics__c='Introduction Anypoint Platform, Debug Mule Application, Structuring Mule Applications';
    trainingSchedule.Topic__c='Mulesoft';
    insert trainingSchedule;

    Employee_Training__c empTraining =new Employee_Training__c();
    empTraining.Training_Schedule__c= trainingSchedule.Id;
    empTraining.Employee__c = emp.Id;
    insert empTraining;

    Employee_Training__c empTraining1 =new Employee_Training__c();
    empTraining1.Training_Schedule__c= trainingSchedule.Id;
    empTraining1.Employee__c = emp1.Id;
    insert empTraining1;

   
}
@isTest static void runTrainingMethods()
{
   
    Employee__c empRec=[SELECT Id,First_Name__c,Email__c FROM Employee__c LIMIT 1];
    //System.assertEquals(empRec.First_Name__c,'XYZ');

    Training_Schedule__c trainingSchedule = [SELECT Id FROM Training_Schedule__c WHERE Topic__c = 'Mulesoft' LIMIT 1 ];
    Employee_Training__c empTraining1 = [SELECT Id FROM Employee_Training__c LIMIT 1];

   test.startTest();
   TrainingController.getUpcomingTrainings();
   TrainingController.getEnrolledTrainings();
   TrainingController.enroll(trainingSchedule.Id);
   TrainingController.assignToMe(trainingSchedule.Id);
   TrainingController.decline(empTraining1.Id);
   

   test.stopTest();
}
    @isTest static void runExceptions1() {
        test.startTest();
        try{
       TrainingController.getUpcomingTrainings();
        }catch (exception e0) {
            
        }
        test.stopTest();
    }
    @isTest static void runExceptions2() {
        test.startTest();
        try{
       TrainingController.getEnrolledTrainings();
        }catch (exception e0) {
            
        }
        test.stopTest();
    }
    @isTest static void runExceptions3() {
        test.startTest();
        try{
       TrainingController.enroll(null);
        }catch (exception e0) {
            
        }
        test.stopTest();
    }
    @isTest static void runExceptions4() {
        test.startTest();
        try{
       TrainingController.assignToMe(null);
        }catch (exception e0) {
            
        }
        test.stopTest();
    }
    @isTest static void runExceptions5() {
        test.startTest();
        try{
       TrainingController.decline(null);
        }catch (exception e0) {
            
        }
        test.stopTest();
    }
}