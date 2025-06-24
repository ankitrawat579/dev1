import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUpcomingTrainings from '@salesforce/apex/TrainingController.getUpcomingTrainings';
// import getEnrolledTrainings from '@salesforce/apex/TrainingController.getEnrolledTrainings';
import enroll from '@salesforce/apex/TrainingController.enroll';
import assignToMe from '@salesforce/apex/TrainingController.assignToMe';

export default class UpcomingTrainings extends LightningElement {
    columns = [
        {
            label: 'Topic', fieldName: 'Topic__c', initialWidth: 150,
            wrapText: true
        },
        {
            label: 'Subtopics', fieldName: 'Subtopics__c', initialWidth: 280,
            wrapText: true
        },
        {
            label: 'Schedule Time', fieldName: 'Schedule_Time__c',
            type: 'date',
            typeAttributes: {
                year: "2-digit",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }, initialWidth: 150,
            wrapText: true
        },
        {
            label: 'Trainer Name', fieldName: 'Trainer_Name__c', initialWidth: 150,
            wrapText: true
        },
        {
            type: 'button',
            label: 'Action',
            typeAttributes: {
                //  name: 'enrol',
                label: { fieldName: 'enrollButtonLabel' },
                //  disabled: { fieldName: 'disabled' }
            },
            initialWidth: 150,
            wrapText: true
        }
    ];
    data = [];

    connectedCallback() {
        this.getUpcomingTrainings();
        window.addEventListener('training_update', () => {
            this.getUpcomingTrainings();
        });
    }
    async getUpcomingTrainings() {
        const upcomingTrainings = await getUpcomingTrainings();
        // const enrolledTrainings = await getEnrolledTrainings();
        this.data = upcomingTrainings.map(upcomingTraining => {
            // const enrolledTraining = enrolledTrainings.find(enrolledTraining => enrolledTraining.Id === upcomingTraining.Id);
            // if (enrolledTraining) {
            //     upcomingTraining.disabled = true;
            // }
            upcomingTraining.enrollButtonLabel = upcomingTraining.Trainer_Name__c ? 'Enroll' : 'Assign to me';
            return upcomingTraining;
        });
    }
    async handleRowAction(event) {
        const training = event.detail.row;
        let message;
        if (training.Trainer_Name__c) {
            await enroll({ trainingId: training.Id });
            message = 'Enrolled successfully.';
        } else {
            await assignToMe({ trainingId: training.Id });
            message = 'Assigned successfully.';
        }
        const successEvent = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message
        });
        this.dispatchEvent(successEvent);
        const updateEvent = new Event("training_update");
        window.dispatchEvent(updateEvent);
    }
}