import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import Name from '@salesforce/schema/User.Name';
import getActiveDelegationAccess from '@salesforce/apex/UserDelegationHandler.getActiveDelegationAccess';
// import getSubordinateUsersBySearchKey from '@salesforce/apex/UserDelegationHandler.getSubordinateUsersBySearchKey';
import queryCloneFrom from '@salesforce/apex/UserDelegationHandler.queryCloneFrom';

export default class POCuserDelegation extends LightningElement {
    // userId = Id;
    userName;
    searchCloneFromKey;
    searchCloneToKey;
    @track selectedCloneToUserId = '';
    @track filteredCloneToUsers = [];
    @track selectedOption = 'myDelegated';
    @track showMyDelegatedAccess = true;
    @track showSubmitDelegation = false;
    @track requestFor = 'peer';
    hideCheckbox = true;
    @track tableData =[];
    showDetail = false;
    @track isDisabled = true;
    options = [];

    @track userData = [];        
    @track filteredUsers = [];
    @track displayUserName = '';
    @track selectedUserId = ''; 
    
    get isMyDelegatedSelected() {
        return this.selectedOption === 'myDelegated';
    }

    get isSubmitDelegationSelected() {
        return this.selectedOption === 'submitDelegation';
    }

    get disableSubmitDelegation() {
        return !this.isPermissionSetAssigned;
    }

    get showLookupDropdown() {
        return this.searchCloneFromKey && this.searchCloneFromKey.length >= 2 && this.filteredUsers.length > 0;
    }

    get showLookupCloneTo() {
        return this.searchCloneToKey && this.searchCloneToKey.length >= 2 && this.filteredCloneToUsers.length > 0;
    }
    
    requestForOptions = [
        { label: 'My Delegate (Peer/Sub-ordinate)', value: 'peer' },
        { label: 'Additional Duties (Sub-ordinate)', value: 'additional' }
    ];

    // My Delegated Access Table
    columns = [
        { label: 'Action', fieldName: 'actionLabel', type: 'button', typeAttributes: { label: { fieldName: 'actionLabel' }, variant: 'brand', disabled: { fieldName: 'isDisabled' } } },
        { label: 'Request Type', fieldName: 'requestType' },
        { label: 'Requested By', fieldName: 'requestedBy' },
        { label: 'Role', fieldName: 'role' },
        { label: 'Branch', fieldName: 'branch' }
    ];

    // Preview Table
    previewColumns = [
        { label: 'Clone From', fieldName: 'cloneFrom' },
        { label: 'Name', fieldName: 'name' },
        { label: 'Role', fieldName: 'role' },
        { label: 'Profile', fieldName: 'profile' },
        { label: 'Branch', fieldName: 'branch' }
    ];

    previewData = [
        { id: '1', cloneFrom: 'ABC', name: '', role: '', profile: '', branch: '' }
    ];

    // Delegation History Table
    historyColumns = [
        { label: 'Action', fieldName: 'action', type: 'button', typeAttributes: { label: { fieldName: 'action' }, variant: 'destructive' } },
        { label: 'Request Type', fieldName: 'requestType' },
        { label: 'Clone From', fieldName: 'cloneFrom' },
        { label: 'Clone To', fieldName: 'cloneTo' },
        { label: 'Role', fieldName: 'role' },
        { label: 'Branch', fieldName: 'branch' }
    ];

    historyData = [
        { id: '1', action: 'Revoke Access', requestType: 'Peer', cloneFrom: 'ABC', cloneTo: 'James Bond', role: '', branch: '' },
        { id: '2', action: 'Expired', requestType: 'Elevated', cloneFrom: 'ABC', cloneTo: 'XYZ', role: '', branch: '' }
    ];
    
    delegationAccess;
    error;
    @wire(getActiveDelegationAccess)
    wiredDelegationAccess({ error, data }) {
    if (data) {
            console.log('Delegation Access Data: ', data);
            // this.userData = data.lstOfUser.map(user => user.Name);
            // console.log('this.userData??? ',this.userData);
            this.isPermissionSetAssigned = data.isPermissionSetAssigned;

            this.tableData = data.lstOfActiveDelagationAccess.map((record) => ({
                id: record.Id,
                actionLabel: 'Current Access', //'Switch Access', 
                isDisabled: true, //here if action label is 'Switch access' then only it is 'true' else 'false'
                requestType: record.Request_Type__c,
                requestedBy: record.Name,
                role: '', 
                branch: ''
            }));

            // console.log('Mapped Table Data:::: ', this.tableData);
            this.error = undefined;
        } else if (error) {
            console.log('error??? ',error);
            this.error = error;
            this.tableData = [];
        }
    }

     @wire(getRecord, { recordId: Id, fields: [Name] })
      userDetails({ error, data }) {
        if (data) {
            console.log('user??', this.userId);
            if (data.fields.Name.value != null) {
                this.userName = data.fields.Name.value;
                console.log('this.userName??? ',this.userName);
            }
        }
    }

    handleOptionChange(event) {
        this.selectedOption = event.target.value;
        console.log('this.selectedOption??? ',this.selectedOption);
        this.showMyDelegatedAccess = this.selectedOption === 'myDelegated';
        this.showSubmitDelegation = this.selectedOption === 'submitDelegation';
        this.showDetail = false; // it hides the popup shown after clicking on preview
        this.searchCloneFromKey = (this.requestFor === 'peer') ? this.userName : '';
        // if(this.showSubmitDelegation){
        //     this.requestFor = 'peer';
        // }
    }

    handleRequestForChange(event) {
        this.requestFor = event.detail.value;
        this.isDisabled = this.requestFor === 'peer';
        if (this.requestFor === 'peer') {
            this.searchCloneFromKey = this.userName;
        } else {
            this.searchCloneFromKey = '';
            queryCloneFrom()
            .then(result => {
                console.log('result??? ',result);
                this.userData = result.map(user => user.Name);
            })
            .catch(error => {
                console.error('Error fetching user details:', error);
            });
        }
        this.showDetail = false;
    }

    handlePreivew(){
        this.showDetail = true;
    }

    handleFormInputChange(event) {
        this.showDetail = false;
        this.searchCloneToKey = event.target.value;

        if (this.searchCloneToKey.length >= 2) {
            const lowerKey = this.searchCloneToKey.toLowerCase();
            if(this.requestFor === 'additional') {
                this.filteredCloneToUsers = this.filteredCloneToUserData.filter(userName =>
                    userName.toLowerCase().includes(lowerKey)
                ).map((name, index) => {
                    return {
                        Id: index.toString(),
                        Name: name
                    };
                });
            } else {
            this.filteredCloneToUsers = this.userData.filter(userName =>
                    userName.toLowerCase().includes(lowerKey)
                ).map((name, index) => {
                    return {
                        Id: index.toString(),
                        Name: name
                    };
                });
            }
            
        } else {
            this.filteredCloneToUsers = [];
        }
    }
    
    handleSearch(event) {
        this.searchCloneFromKey = event.target.value;
        this.showDetail = false; // hide preview on typing

        if (this.searchCloneFromKey.length >= 2) {
            const lowerKey = this.searchCloneFromKey.toLowerCase();
            this.filteredUsers = this.userData.filter(userName =>
                userName.toLowerCase().includes(lowerKey)
            ).map((name, index) => {
                return {
                    Id: index.toString(),
                    Name: name
                };
            });
        } else {
            this.filteredUsers = [];
        }
    }

    handleCloneFromSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const userName = event.currentTarget.dataset.name;

        this.selectedUserId = userId;
        this.displayUserName = userName;
        this.searchCloneFromKey = userName;
        this.filteredUsers = [];
        this.showDetail = false; // Hide preview on selecting a different user
        /*
        getSubordinateUsersBySearchKey({ searchKey: userName })
        .then(result => {
            console.log('Apex result:218:', result);
        })
        .catch(error => {
            console.error('Error fetching user details:', error);
        });*/

        this.filteredCloneToUserData = this.userData.filter(name => name !== userName);
    }

    handleCloneToSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const userName = event.currentTarget.dataset.name;

        this.selectedCloneToUserId = userId;
        this.searchCloneToKey = userName;
        this.filteredCloneToUsers = [];
        this.showDetail = false; // Hide preview on selecting a different user
    }

}