// Apex Class
public with sharing class GetEmployeeDetails {

    @AuraEnabled(cacheable = true)
    public static calenderDetailsWrapper getEmployeeLeaves() {
        try {
            calenderDetailsWrapper resultWrapper = new calenderDetailsWrapper();
            List<User> lstUser = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            String loggedInUserName = lstUser[0].Name;
            Set<Date> leaveDateSet = new Set<Date>();
            Map<String, String> totalHoursMap = new Map<String, String>();

            List<Employee__c> empDetail = [
                SELECT Id, Name,
                    (SELECT Id, Start_Date__c, End_Date__c FROM Leaves__r),
                    (SELECT Id, In_Time__c, Out_Time__c, Total_Time__c FROM Attendances__r)
                FROM Employee__c 
                WHERE Name =: loggedInUserName LIMIT 1
            ];

            if (!empDetail.isEmpty()) {
                for (Leave__c leave : empDetail[0].Leaves__r) {
                    if (leave.Start_Date__c != null && leave.End_Date__c != null) {
                        Date current = leave.Start_Date__c;
                        while (current <= leave.End_Date__c) {
                            leaveDateSet.add(current);
                            current = current.addDays(1);
                        }
                    }
                }

                // for Attandance coloring

               for (Attendance__c att : empDetail[0].Attendances__r) {
                if (att.In_Time__c != null && att.Out_Time__c != null && att.Total_Time__c != null) {
                    if (att.In_Time__c.date() == att.Out_Time__c.date()) {
                        Date onlyDate = att.In_Time__c.date();
                        String dateStr = String.valueOf(onlyDate);
                        totalHoursMap.put(dateStr, att.Total_Time__c);
                        }
                    }
                }

            }

            List<String> leaveDateStrings = new List<String>();
            for (Date d : leaveDateSet) {
                leaveDateStrings.add(String.valueOf(d));
            }
            resultWrapper.lstOfLeave = leaveDateStrings;

            List<Holiday> holidays = [
                SELECT ActivityDate FROM Holiday 
                WHERE ActivityDate >= :Date.newInstance(Date.today().year(), 1, 1)
                AND ActivityDate <= :Date.newInstance(Date.today().year(), 12, 31)
            ];
            List<String> holidayDateStrings = new List<String>();
            for (Holiday h : holidays) {
                if (h.ActivityDate != null) {
                    holidayDateStrings.add(String.valueOf(h.ActivityDate));
                }
            }
            resultWrapper.lstOfHoliday = holidayDateStrings;
            resultWrapper.totalHoursMap = totalHoursMap;

            return resultWrapper;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class calenderDetailsWrapper {
        @AuraEnabled public List<String> lstOfLeave { get; set; } 
        @AuraEnabled public List<String> lstOfHoliday { get; set; }
        @AuraEnabled public Map<String, String> totalHoursMap { get; set; }
    }
}