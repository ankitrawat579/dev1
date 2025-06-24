/**
* @File Name : leadManageHandler.cls
* @Description :
* @Author : Ankit Rawat
* @Last Modified By :
* @Last Modified On : April 14, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 14, 2025 |   | Initial Version
**/

public with sharing class leadManageHandler {

    @AuraEnabled(cacheable=true)
    public static List<Lead__c> getAllLeads() {
        // return [SELECT Id, FirstName, LastName, Company, Email, Phone FROM Lead];
		return[SELECT Id, Email__c, Company__c FROM Lead__c];
    }

    @AuraEnabled
    public static void updateLeads(List<Lead> leadsToUpdate) {
        if (leadsToUpdate != null && !leadsToUpdate.isEmpty()) {
            List<Lead> leadsToUpdateList = new List<Lead>();
            for (Lead lead : leadsToUpdate) {
                // Only update fields that are passed
                Lead l = new Lead(
                    Id = lead.Id,
                    // FirstName = lead.FirstName,
					// LastName = lead.LastName,
                    Company = lead.Company,
                    Email = lead.Email,
                    Phone = lead.Phone
                );
                leadsToUpdateList.add(l);
            }
            update leadsToUpdateList;
        }
    }

    @AuraEnabled
    public static void deleteLead(Id leadId) {
        if (leadId != null) {
            Lead l = [SELECT Id FROM Lead WHERE Id = :leadId LIMIT 1];
            delete l;
        }
    }
}