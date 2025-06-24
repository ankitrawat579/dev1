public with sharing class FileUploadController {

    @AuraEnabled
    public static void uploadFile(Id recordId, String fileName, String base64Data) {

        if (String.isBlank(base64Data) || String.isBlank(fileName)) {
            throw new AuraHandledException('Invalid file data.');
        }


        Blob fileBody = EncodingUtil.base64Decode(base64Data);


        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = fileBody;
        insert cv;


        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];


        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = recordId; 
        cdl.ShareType = 'V'; 
        cdl.Visibility = 'AllUsers';
        insert cdl;

		 Candidate__c candidate = [
            SELECT Id, Position__c , Upload_CV__c 
            FROM Candidate__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];

		List<Job_Application__c> lstJobApplication = [SELECT Id FROM Job_Application__c WHERE Candidate__c =: recordId ];
		if(lstJobApplication.isempty() ) {
			Job_Application__c objJobApplication = new Job_Application__c(
			Candidate__c = recordId, 

            Position__c = candidate.Position__c
       
			);
        insert objJobApplication;
		} 

		    candidate.Upload_CV__c = true;
        update candidate;
		
    }

}