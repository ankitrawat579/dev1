import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploadController.uploadFile';

export default class CvUpload extends LightningElement {
    @api recordId;
     @track isLoading = false;
    selectedFile;

    triggerFileInput() {
        this.template.querySelector('.fileInput').click();
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) return;

        if (file.size > 20971520) { // 20 MB limit
            this.showToast('Error', 'File size cannot exceed 20MB', 'error');
            return;
        }

        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            this.uploadToServer(file.name, base64);
        };
        reader.readAsDataURL(file);
    }

   uploadToServer(fileName, base64) {
    this.isLoading = true; // Start spinner
    uploadFile({ recordId: this.recordId, fileName, base64Data: base64 })
        .then(() => {
            this.showToast('Success', 'File uploaded successfully', 'success');
            this.dispatchEvent(new CustomEvent('refresh'));
                window.location.reload();
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.isLoading = false; // Stop spinner


        });
}

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}