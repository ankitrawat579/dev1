public class RecordDataHelper {
    public static List<Map<String, String>> getRecordList() {
        List<Map<String, String>> records = new List<Map<String, String>>();

        records.add(new Map<String, String>{
            'Name' => 'Alex',
            'Phone' => '1234567890',
            'Email' => 'alex@example.com',
            'City' => 'Dhaka',
            'Id' => '00001'
        });

        records.add(new Map<String, String>{
            'Name' => 'Martin',
            'Phone' => '9876543210',
            'Email' => 'martin@example.com',
            'City' => 'Mumbai',
            'Id' => '00002'
        });

        records.add(new Map<String, String>{
            'Name' => 'Mac',
            'Phone' => '99999111111',
            'Email' => 'mac@example.com',
            'City' => 'Delhi',
            'Id' => '00003'
        });

        return records;
    }
}