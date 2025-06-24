import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import orgChartJSF from '@salesforce/resourceUrl/orgChartJSF';
import getEmployeeDetails from '@salesforce/apex/EmployeeHierarchyController.getEmployeeDetails';

export default class OrgchartLWC extends LightningElement {
    error;
    chart;
    initialized = false;

    @api recordId;
    employees = [];

    renderedCallback() {
        if (this.initialized) return;
        this.initialized = true;

        Promise.all([
                loadScript(this, orgChartJSF)
            ])
            .then(() => {
                return getEmployeeDetails();
            })
            .then(result => {
                this.employees = result.map(employee => ({
                    id: employee.orgChartId__c,
                    pid: employee.orgChartParentId__c,
                    name: employee.Name,
                    designation: employee.Designation__c
                    // Photourl: employee.Connected_User__r.SmallPhotoUrl

                }));
                this.initialize();
                })
            .catch((error) => {
                this.error = error;  
            });         
    }

    initialize() {
        this.chart = new OrgChart(this.template.querySelector('[data-id="tree"]'), { 
            template: "isla", 
            nodeBinding: {
                field_0: "name",
                field_1: "designation",
                // img_0: "Photourl"
            },
            nodes: this.employees
        }); 
       
        this.chart.load(this.employees);
    }
}