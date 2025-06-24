import { LightningElement, track, wire } from 'lwc';
import getPerformanceFlag from '@salesforce/apex/EmployeePortalController.getPerformanceFlag';

export default class PerformanceFlag extends LightningElement {
    @track textColor = 'black'; 
    @track backgroundColor;

    @wire(getPerformanceFlag)
    wiredPerformanceFlag({ error, data }) {
        if (data) {
            if (Array.isArray(data) && data.length > 0) {
                this.performanceFlag = data[0].Color_Code__c;
                
                if (this.performanceFlag) {
                    this.backgroundColor = `background-color: ${this.performanceFlag};`;                
                    this.updateTextColor(this.performanceFlag);
                } 
            } 
        } else if (error) {
            console.log('Error fetching record:', error);
        }
    }

    updateTextColor(color) {
    if (color === '#008000' || color === '#FF0000') {
        this.textColor = 'white';
    } else {
        this.textColor = 'black'; 
    }
    }
    
    get textStyle() {
        return `color: ${this.textColor};`;
    }
}