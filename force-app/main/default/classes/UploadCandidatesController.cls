public class UploadCandidatesController {

    @InvocableMethod(label= 'UploadCandidatesController' description= 'Convert CSV file to Records')
    public static void convertCSVFile(List<List<Id>> contentVersionIds) {
        System.debug('contentVersionIds::'+contentVersionIds);
        List<Id> conVersionIds = contentVersionIds[0];

        for (ContentVersion con : [SELECT Id, VersionData, Title FROM ContentVersion WHERE Id IN : conVersionIds]) {
            String csvData = con.VersionData.toString();
            System.debug('Raw CSV: ' + csvData);
            System.debug('Raw CSV: ' + json.serialize(csvData));
            List<String> lines = csvData.split('\r\n');

            if (lines.size() < 2) {
                System.debug('No data found in file.');
                continue;
            }

            List<String> headers = lines[0].trim().split(',');
			System.debug('headers>> '+headers);
            // This list for JSON Formatter
            List<Map<String, String>> recordsList = new List<Map<String, String>>();

            for (Integer i = 1; i < lines.size(); i++) {
                String row = lines[i].trim();
                if (String.isBlank(row)) continue;

                List<String> values = row.split(',');
                Map<String, String> recordMap = new Map<String, String>();

                for (Integer j = 0; j < headers.size() && j < values.size(); j++) {
                    recordMap.put(headers[j].trim(), values[j].trim());
                }

                recordsList.add(recordMap);
            }

            String jsonOutput = JSON.serialize(recordsList);
            System.debug('Parsed JSON: ' + jsonOutput);
			
            
        }
    }

    public class InvokedApex {
        @InvocableVariable
        public List<List<Id>> contentVersionIds;
    }
}