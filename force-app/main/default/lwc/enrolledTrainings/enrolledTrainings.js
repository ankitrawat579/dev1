import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEnrolledTrainings from '@salesforce/apex/TrainingController.getEnrolledTrainings';
import decline from '@salesforce/apex/TrainingController.decline';

export default class EnrolledTrainings extends LightningElement {
    columns = [
        {
            label: 'Topic', fieldName: 'Topic__c', initialWidth: 98,
            wrapText: true
        },
        // {
        //     label: 'Subtopics', fieldName: 'Subtopics__c', initialWidth: 150,
        //     wrapText: true
        // },
        {
            label: 'Schedule Time', fieldName: 'Schedule_Time__c', 
            type: 'date',
            typeAttributes: {
                year: "2-digit",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }, initialWidth: 134,
            wrapText: true
        },
        {
            label: 'Trainer Name', fieldName: 'Trainer_Name__c', initialWidth: 98,
            wrapText: true
        },
        {
            type: 'button',
            label: 'Action',
            typeAttributes: {
                label: "Decline"
            }, initialWidth: 98, wrapText: true
        }
    ];
    data = [];

    connectedCallback() {
        this.getEnrolledTrainings();
        window.addEventListener('training_update', () => {
            this.getEnrolledTrainings();
        });
    }

    async getEnrolledTrainings() {
        const enrolledTrainings = await getEnrolledTrainings();
        this.data = enrolledTrainings.map(enrolledTraining => {
            return enrolledTraining;
        });
    }
    async handleRowAction(event) {
        await decline({ trainingId: event.detail.row.Id });
        const successEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Decline successfully.',
            variant: 'success'
        });
        this.dispatchEvent(successEvent);
        const updateEvent = new Event("training_update");
        window.dispatchEvent(updateEvent);
    }
}