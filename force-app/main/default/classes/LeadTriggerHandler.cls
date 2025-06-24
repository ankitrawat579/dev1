public class LeadTriggerHandler {
    public static void handleAfterInsert(List<Lead> newLeads) {
            if (newLeads == null || newLeads.isEmpty()) {
                return;
            }
            
            List<Lead__c> lstOfCustomLead = new List<Lead__c>();
            
            for (Lead leadRec : newLeads) {
                Lead__c customLead = new Lead__c();
                customLead.Name = leadRec.FirstName + ' ' + leadRec.LastName;
                customLead.Phone__c = leadRec.Phone;
                customLead.Email__c = leadRec.Email;
                customLead.Company__c = leadRec.Company;
                customLead.Lead_Status__c = leadRec.Status;
                customLead.Website__c = leadRec.Website;
                customLead.Description__c = leadRec.Description;
                
                
                lstOfCustomLead.add(customLead);
            }
            
            if (!lstOfCustomLead.isEmpty()) {
                insert lstOfCustomLead;
            }
        }
}