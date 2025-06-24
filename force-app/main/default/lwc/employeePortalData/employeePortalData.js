import { LightningElement, api, wire } from 'lwc';
import getData from '@salesforce/apex/EmployeePortalDataController.getData';



export default class EmployeePortalData extends LightningElement {
    records;
    columns;
    selectedColumns;
    recordId;
    is_Single;
    id;
    isError;
    errorMessage;
    holidayRecords;
    holidayColumns;
    @api dType;
    @api sectionheading;
    @api isSingle;
    @api isHoliday;
    @api orderBy;
    @api orderType;
    @api limit;
    
   

    holidayColumns=[
        { label: 'HolidayName', fieldName: 'Name' , type:'text'},
        { label: 'HolidayDate', fieldName: 'ActivityDate' , type:'text'}
     ]



    @wire(getData, { dataType: '$dType', isSingle: '$isSingle', orderBy: '$orderBy', orderType: '$orderType', limits: '$limit'})
    fetchRecords({data,error}) {
        if (data)
            {
            //for single record
            this.columns = data.columns;
            this.is_Single = data.isSingle;
            this.recordId = data.recordId;    
            //for multi record
            this.records = data.records;
            this.selectedColumns = data.tableColumns;
            this.orderBy = data.orderBy;
            this.orderType = data.orderType;
            this.limits = data.limits;
            //for Holiday
            this.holidayRecords=data.holidayRecords;
            this.orderBy = data.orderBy;
            this.orderType = data.orderType;
            this.limits = data.limits;
            //for any type of record
            console.log("errorMessage:",data.errorMessage);
            this.isError=data.isError;
            this.errorMessage=data.errorMessage;
           
        }
        else {
            this.error = error;
        }
    }     
}