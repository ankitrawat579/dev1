import { LightningElement, track, api, wire } from 'lwc';
import getEmployeeDetail from '@salesforce/apex/FetchEmpDetails.getEmployeeDetail';
import getCompensationDetail from '@salesforce/apex/FetchEmpDetails.getCompensationDetail';

export default class getEmployeeData extends LightningElement {


    records;
    columns;
    recordId;
    is_Single;
    id;
    @api dType;
    @api isSingle;
    @track DataTableResponseWrappper;
    @track finalSObjectDataList;

    @wire(getEmployeeDetail, { dataType: '$dType', isSingle: '$isSingle' })
    fetchRecords({ data, error }) {
        if (data) {
            this.records = data.records;
            this.columns = data.columns;
            this.is_Single = data.isSingle;
            this.recordId = data.recordId;
        }
    }
    @wire(getCompensationDetail, { dataType: '$dType', isSingle: '$isSingle' })
    getRecords({ data, error }) {
        if (data) {
            let sObjectRelatedFieldListValues = [];

            for (let row of data.records) {
                const finalSobjectRow = {}
                let rowIndexes = Object.keys(row);
                rowIndexes.forEach((rowIndex) => {
                    const relatedFieldValue = row[rowIndex];
                    if (relatedFieldValue.constructor === Object) {
                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
                    }
                    else {
                        finalSobjectRow[rowIndex] = relatedFieldValue;
                    }

                });
                sObjectRelatedFieldListValues.push(finalSobjectRow);
            }
            this.DataTableResponseWrappper = data;
            //Console.log('DataTableResponseWrappper ===  '+this.DataTableResponseWrappper);
            this.finalSObjectDataList = sObjectRelatedFieldListValues;
            // Console.log('finalSObjectDataList == ' +this.finalSObjectDataList);
        }
        else if (error) {
            this.error = error;
        }
    }
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }
}