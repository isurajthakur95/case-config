import { LightningElement , wire , track , api} from 'lwc';
import getConfigData from '@salesforce/apex/CaseConfigController.getConfigData';
import addConfigData from '@salesforce/apex/CaseConfigController.addConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import REFRESH_CASE from '@salesforce/messageChannel/Refresh_Case__c';

const columns = [
    { label: 'Label', fieldName: 'Label__c', sortable: true },
    { label: 'Type', fieldName: 'Type__c', sortable: true },
    { label: 'Amount', fieldName: 'Amount__c', sortable: true }
];

const errorVariant = 'error';
const errorTitle = 'ERROR';
const successVariant = 'success';
const successTitle = 'SUCCESS';

export default class AvailableConfigs extends LightningElement {
    @api recordId;
    @track configData = [];
    columns = columns;
    @track sortBy;
    @track sortDir;
    @track disableButton = true;


    @wire(getConfigData , {recordId : '$recordId'})
    getConfigData({data,error}){
        if (data) {
            this.configData = data;
        } else if (error) {
            this.handleToastMessage(errorTitle, error , errorVariant);
        }
    }

    connectedCallback() {
    }

    doSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDir = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDir);
    }

    sortData(fieldname, direction) {
        let parseDataCloned = JSON.parse(JSON.stringify(this.configData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseDataCloned.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.configData = parseDataCloned;
    }

    rowSelectionAction(event){
        const selectedRows = event.detail.selectedRows;
        if(selectedRows.length > 0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }

    handleClickAdd(event){
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        this.handleAddConfigData(selectedRecords);
    }

    handleAddConfigData(selectedRecords){
        addConfigData({recordId : this.recordId, newConfigRecs : selectedRecords})
        .then(result =>{
            if(result){
                this.handleToastMessage(successTitle, 'Records Inserted Successfully' , successVariant);
                let clonedConfigData = this.configData;
                this.configData = this.removeElements(clonedConfigData, selectedRecords);
                this.refreshCaseRecord();
            }
        })
        .catch(error =>{
            this.handleToastMessage(errorTitle, error , errorVariant);
        })
    }

    removeElements(currentConfigRecs, currentSelectedRecords){
        return currentConfigRecs.filter(currentConfigRec => {
            return !currentSelectedRecords.some(currentSelectedRec => currentConfigRec.Label__c === currentSelectedRec.Label__c);
        });
    }

    @wire(MessageContext)
    messageContext;

    refreshCaseRecord(){
        const caseData = {
            recordId: this.recordId
        }
        publish(this.messageContext, REFRESH_CASE, caseData);
    }

    handleToastMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
