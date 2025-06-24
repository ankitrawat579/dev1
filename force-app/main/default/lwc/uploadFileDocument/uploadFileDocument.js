import { LightningElement, api, track, wire } from 'lwc';
import uploadFile from '@salesforce/apex/FileUploaderHandler.uploadFile';
import fetchUploadedFileNames from '@salesforce/apex/FileUploaderHandler.fetchUploadedFileNames';
import getRecordTypeName from '@salesforce/apex/FileUploaderHandler.getRecordTypeName';
import getBase64File from '@salesforce/apex/FileUploaderHandler.getBase64File';
import getFileName from '@salesforce/apex/FileUploaderHandler.getFileName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


export default class UploadFileDocument extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track recordType;
    @track fulloptions = [];
    @track isModalOpen = false;
    @track previewFileUrl = '';
    @track fileMimeType = 'application/pdf';
    @track fileName;
    @track documentOptions = [
        { label: 'Cadidate Photo', checked: false, fileName: '', fileSizeError: '', key: 'photo' },
        { label: 'KYC', checked: false, fileName: '', fileSizeError: '', key: 'kyc' },
        { label: 'Marksheet', checked: false, fileName: '', fileSizeError: '', key: 'marksheet' },
        { label: 'Offer Letter / Appraisal', checked: false, fileName: '', fileSizeError: '', key: 'offer' },
        { label: 'Relieving/Experience Letter', checked: false, fileName: '', fileSizeError: '', key: 'experience' },
        { label: '3 Months Salary Slip/Bank Statement', checked: false, fileName: '', fileSizeError: '', key: 'salary' }
    ];

    wiredFileResult;
    uploadedFilesResult = [];

    get isImageFile() {
        return this.fileMimeType?.startsWith('image/');
    }

    get isPdfFile() {
        return this.fileMimeType === 'application/pdf';
    }

    connectedCallback() {
        this.fetchRecordType();
    }

    @wire(fetchUploadedFileNames, { parentId: '$recordId' })
    wiredFiles(result) {
        setTimeout(() => {
            this.wiredFileResult = result;
            const { data, error } = result;
            if (data) {
                this.uploadedFilesResult = data;
                this.updateDocumentOptions(data);
            } else if (error) {
                this.showToast('Error', 'Failed to fetch uploaded file names', 'error');
            }
        }, 1000);
    }

    fetchRecordType() {
        this.isLoading = true;
        getRecordTypeName({ recordId: this.recordId })
            .then(result => {
                this.recordType = result;
                this.setFullOptions();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    setFullOptions() {
        const isFresher = this.recordType?.toLowerCase().includes('fresher');
        const filteredOptions = isFresher
            ? this.documentOptions.filter(opt => ['photo', 'kyc', 'marksheet'].includes(opt.key))
            : [...this.documentOptions];
        this.fulloptions = filteredOptions.map((opt, index) => ({
            ...opt,
            serial: index + 1
        }));
    }

    updateDocumentOptions(data) {
        this.documentOptions = this.documentOptions.map(doc => {
            const match = data.find(item => item.documentLabel === doc.label);
            const uploaded1 = match?.fileUploaded || false;
            const uploaded2 = match?.fileUploaded2 || false;
            return match
                ? {
                      ...doc,
                      fileName: match.name,
                      checked: true,
                      contentVersionId: match.contentVersionId,
                      disableUpload: uploaded1 && uploaded2
                  }
                : doc;
        });

        const isFresher = this.recordType?.toLowerCase().includes('fresher');
        const filteredOptions = isFresher
            ? this.documentOptions.filter(opt => ['photo', 'kyc', 'marksheet'].includes(opt.key))
            : [...this.documentOptions];

        this.fulloptions = filteredOptions.map((opt, index) => ({
            ...opt,
            serial: index + 1
        }));
    }

    handleLightningFileUpload(event) {
        const label = event.target.dataset.label;
        const uploadedFiles = event.detail.files;

        if (!uploadedFiles || uploadedFiles.length === 0) {
            this.showToast('Error', 'No file uploaded', 'error');
            return;
        }

        const fileName = uploadedFiles[0].name;
        const contentVersionId = uploadedFiles[0].contentVersionId;
        this.isLoading = true;

        uploadFile({
            fileName,
            parentId: this.recordId,
            label,
            contentVersionId
        })
            .then(result => {
                if (result === true) {
                    this.showToast('Success', 'File uploaded successfully', 'success');
                    this.documentOptions = this.documentOptions.map(doc =>
                        doc.label === label
                            ? { ...doc, checked: true, fileName, contentVersionId }
                            : doc
                    );

                    const isFresher = this.recordType?.toLowerCase().includes('fresher');
                    const filteredOptions = isFresher
                        ? this.documentOptions.filter(opt => ['photo', 'kyc', 'marksheet'].includes(opt.key))
                        : [...this.documentOptions];

                    this.fulloptions = filteredOptions.map((opt, index) => ({
                        ...opt,
                        serial: index + 1
                    }));

                    return refreshApex(this.wiredFileResult);
                } else {
                    this.showToast('Error', 'File upload limit exceeded', 'error');
                }
            })
            .catch(error => {
                const msg = error.body?.message || 'Upload failed';
                this.showToast('Error', msg, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }



    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handlePreview(event) {
        const contentVersionId = event.currentTarget.dataset.versionId;
        if (!contentVersionId) {
            this.showToast('Error', 'No file available for preview', 'error');
            return;
        }

        getFileName({ contentVersionId }).then(result => {
            this.fileName = result;
        });

        this.isLoading = true;

        getBase64File({ contentVersionId })
            .then(base64 => {
                const fileType = base64.substring(0, 5).includes('iVBOR') ? 'image/png' :
                    base64.substring(0, 5).includes('/9j/4') ? 'image/jpeg' :
                        'application/pdf';

                this.previewFileUrl = `data:${fileType};base64,${base64}`;
                this.fileMimeType = fileType;
                this.isModalOpen = true;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to preview file', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    closeModal() {
        this.isModalOpen = false;
        this.previewFileUrl = '';
    }

    downloadPreviewFile() {
        const title = this.fileName || 'downloaded_file';

        if (this.previewFileUrl) {
            const link = document.createElement('a');
            link.href = this.previewFileUrl;
            link.download = title;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } else {
            this.showToast('Error', 'No file available for download', 'error');
        }
    }

    handleUploadIconClick(event) {
        const isDisabled = event.currentTarget.dataset.disabled === 'true';
        const label = event.currentTarget.dataset.label;
        console.log('isDisabled???', isDisabled);
        console.log('label?? ',label);
        if (isDisabled) {
            this.showToast('Upload Blocked', `You cannot upload more than 2 files for "${label}".`, 'error');
            event.preventDefault();
            event.stopPropagation();
        }
    }
    
}