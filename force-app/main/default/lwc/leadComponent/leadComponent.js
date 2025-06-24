import { LightningElement, wire, track } from 'lwc';
import getAllLeads from '@salesforce/apex/leadManageHandler.getAllLeads';
import updateLeads from '@salesforce/apex/leadManageHandler.updateLeads';
import deleteLead from '@salesforce/apex/leadManageHandler.deleteLead';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadComponent extends LightningElement {
    @track leads = [];
    @track draftValues = [];
    wiredLeadsResult;

    columns = [
        { label: 'Id', fieldName: 'Id', type: 'text', editable: false },
        { label: 'First Name', fieldName: 'First_Name__c', type: 'text', editable: true },
        { label: 'last Name', fieldName: 'Last_Name__c', type: 'text', editable: true },
        { label: 'Company', fieldName: 'Company__c', type: 'text', editable: true },
        { label: 'Email', fieldName: 'Email__c', type: 'email', editable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Delete', name: 'delete' }
                ],
            },
        },
    ];

    @wire(getAllLeads)
    leadData(result) {
        this.wiredLeadsResult = result;
        const { data, error } = result;
        if (data) {
            this.leads = data;
        } else if (error) {
            console.error(error);
            this.showToast('Error', 'Error fetching leads', 'error');
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('updatedFields>>> ',updatedFields);
        updateLeads({ leadsToUpdate: updatedFields })
            .then(() => {
                this.showToast('Success', 'Leads updated successfully!', 'success');
                this.draftValues = [];
                return refreshApex(this.wiredLeadsResult);
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error updating leads', 'error');
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.deleteLead(row.Id);
        }
    }

    deleteLead(leadId) {
        deleteLead({ leadId: leadId })
            .then(() => {
                this.showToast('Success', 'Lead deleted successfully!', 'success');
                return refreshApex(this.wiredLeadsResult);
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error deleting lead', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}