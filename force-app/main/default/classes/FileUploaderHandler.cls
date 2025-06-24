public with sharing class FileUploaderHandler {
    public static Boolean isUploadComplete = false;

    @AuraEnabled
    public static Boolean uploadFile(String fileName, String parentId, String label, String contentVersionId) {
        try {
            if (String.isBlank(fileName) || String.isBlank(parentId) || String.isBlank(label) || String.isBlank(contentVersionId)) {
                throw new AuraHandledException('Missing required information.');
            }

            ContentVersion version = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersionId
                LIMIT 1
            ];

            Id contentDocumentId = version.ContentDocumentId;

            List<Custom_File__c> existing = [
                SELECT Id
                FROM Custom_File__c
                WHERE Review__c = :parentId AND Document_Label__c = :label
                LIMIT 1
            ];
            
            String fileNameWithoutExtension = fileName;
            Integer dotIndex = fileName.lastIndexOf('.');

            if (dotIndex != -1 && dotIndex > 0) {
                fileNameWithoutExtension = fileName.substring(0, dotIndex);
            }

            if (existing.isEmpty()) {
                insert new Custom_File__c(
                    Review__c = parentId,
                    Document_Label__c = label,
                    Name = fileNameWithoutExtension, //fileName,
                    ContentDocumentId__c = contentDocumentId,
                    File_Uploaded__c = true
                );
            } else {
                Custom_File__c record = existing[0];
                record.Name = fileNameWithoutExtension; //fileName;
                record.ContentDocumentId__c = contentDocumentId;
                record.File_Uploaded_2__c = true;
                update record;
            }

            updateReviewFlags(label, parentId);
            return true;

        } catch (Exception ex) {
            throw new AuraHandledException('Upload failed: ' + ex.getMessage());
        }
    }


    private static void updateReviewFlags(String label, Id parentId) {
        Review__c review = [
            SELECT Id, Marksheets__c, Candidate_photo__c, KYC__c, Appraisal__c, 
                   Salary_Slip_Bank_statement__c, Relieving_Experience_Letter__c
            FROM Review__c 
            WHERE Id = :parentId 
        ];

        if (label == 'Cadidate Photo') {
            review.Candidate_photo__c = true;
        } else if (label == 'KYC') {
            review.KYC__c = true;
        } else if (label == 'Marksheet') {
            review.Marksheets__c = true;
        } else if (label == 'Offer Letter / Appraisal') {
            review.Appraisal__c = true;
        } else if (label == 'Relieving/Experience Letter') {
            review.Relieving_Experience_Letter__c = true;
        } else if (label == '3 Month Salary Slip / Bank statement') {
            review.Salary_Slip_Bank_statement__c = true;
        }

        update review;
    }

    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> fetchUploadedFileNames(String parentId) {
        List<DocumentWrapper> wrappers = new List<DocumentWrapper>();

        if (String.isBlank(parentId) ) { 
            // System.debug('Invalid or blank parentId provided: ' + parentId + '. Returning empty list.');
            return wrappers; 
        }

        List<Custom_File__c> lstCustomFile = [
            SELECT Document_Label__c, Name, File_Uploaded__c, ContentDocumentId__c, File_Uploaded_2__c
            FROM Custom_File__c 
            WHERE Review__c = :parentId
        ];

        Map<String, ContentVersion> labelToContentMap = new Map<String, ContentVersion>();
        for (ContentVersion cv : [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE FirstPublishLocationId = :parentId
            ORDER BY CreatedDate DESC
            LIMIT 100
        ]) {
            labelToContentMap.put(cv.Title, cv); 
        }
        
        for (Custom_File__c objFile : lstCustomFile) {
            String label = objFile.Document_Label__c;
            String name = objFile.Name;

            String contentVersionId = '';
            String contentDocumentIdFromCv = '';
            if (labelToContentMap.containsKey(name)) {
                ContentVersion cv = labelToContentMap.get(name);
                contentVersionId = cv.Id;
                contentDocumentIdFromCv = cv.ContentDocumentId;
             }
             String finalContentDocumentId = String.isNotBlank(objFile.ContentDocumentId__c) ? objFile.ContentDocumentId__c : contentDocumentIdFromCv;
            // String versionId = labelToContentMap.containsKey(name) ? labelToContentMap.get(name).Id : '';
            wrappers.add(new DocumentWrapper(
                label,
                name,
                objFile.File_Uploaded__c,
                objFile.File_Uploaded_2__c,
                contentVersionId,
                finalContentDocumentId
                ));
        }

        return wrappers;
    }

    public class DocumentWrapper {
        @AuraEnabled public String documentLabel { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean fileUploaded { get; set; }
        @AuraEnabled public Boolean fileUploaded2 { get; set; }
        @AuraEnabled public String contentVersionId { get; set; }
        @AuraEnabled public String contentDocumentId { get; set; }

        public DocumentWrapper(String documentLabel, String name, Boolean fileUploaded, Boolean fileUploaded2, String contentVersionId, String contentDocumentId) {
            this.documentLabel = documentLabel;
            this.name = name;
            this.fileUploaded = fileUploaded;
            this.fileUploaded2 = fileUploaded2;
            this.contentVersionId = contentVersionId;
            this.contentDocumentId = contentDocumentId;
        }
    }

    @AuraEnabled
    public static String getRecordTypeName(Id recordId) {
        try {
            Review__c reviewRecord = [
                SELECT RecordType.DeveloperName 
                FROM Review__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            return reviewRecord.RecordType.DeveloperName;
        } catch (Exception ex) {
            return 'No RecordType Found';
        }
    }

    @AuraEnabled
    public static String getBase64File(String contentVersionId) {
        try {
            ContentVersion version = [
                SELECT VersionData 
                FROM ContentVersion 
                WHERE Id = :contentVersionId 
                LIMIT 1
            ];
            return EncodingUtil.base64Encode(version.VersionData);
        } catch (Exception ex) {
            throw new AuraHandledException('Error loading file: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static String getFileName(String contentVersionId) {
        try {
            ContentVersion objCV = [
                SELECT Title 
                FROM ContentVersion 
                WHERE Id = :contentVersionId 
                LIMIT 1
            ];
            return objCV.Title;
        } catch (Exception ex) {
            throw new AuraHandledException('Error loading file: ' + ex.getMessage());
        }
    }
}