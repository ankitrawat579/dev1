public class RecordPageController {
    public String recordsJson { get; set; }
    public Boolean isMultiSelect { get; set; }
    public String errorMessage { get; set; } // upd

    public RecordPageController() {
        RecordsWrapperData wrapper = getRecordsWrapperData();

        recordsJson = JSON.serialize(wrapper.records);
        isMultiSelect = wrapper.isMultiSelect;
    }

    private RecordsWrapperData getRecordsWrapperData() {
        RecordsWrapperData data = new RecordsWrapperData();
        
		// receving data from helper class
        data.records = RecordDataHelper.getRecordList();
        // it should be false for seletction of one record at a time
        data.isMultiSelect = false;

        return data;
    }

    public class RecordsWrapperData {
        public List<Map<String, String>> records { get; set; }
        public Boolean isMultiSelect { get; set; }
    }

    public void fetchErrorMessage() { // upd
        errorMessage = 'Error found';
    }
    
}