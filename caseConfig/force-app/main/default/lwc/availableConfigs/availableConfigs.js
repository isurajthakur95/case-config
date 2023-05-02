import { LightningElement, api, wire, track } from 'lwc';
import getConfigData from '@salesforce/apex/CaseConfigController.getConfigData';
import addConfigData from '@salesforce/apex/CaseConfigController.addConfigData';
import getCaseStatusValue from '@salesforce/apex/CaseConfigController.getCaseStatusValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import REFRESH_CASE from '@salesforce/messageChannel/Refresh_Case__c';

const columns = [
    { label: 'Label', fieldName: 'Label__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Amount', fieldName: 'Amount__c' }
];

/**
 * Constants for toast message variants and titles
 */
const ERROR_VARIANT = 'error';
const ERROR_TITLE = 'ERROR';
const SUCCESS_VARIANT = 'success';
const SUCCESS_TITLE = 'SUCCESS';

/**
 * AvailableConfigs component
 *
 * Displays a list of available configurations and allows the user to select and add them to the current case.
 */
export default class AvailableConfigs extends LightningElement {
    /** The record ID of the current case */
    @api recordId;

    /** The configuration data to display in the table */
    @track configData = [];

    /** The columns to display in the table */
    @track columns = [
        { label: 'Label', fieldName: 'Label__c', sortable: true },
        { label: 'Type', fieldName: 'Type__c', sortable: true },
        { label: 'Amount', fieldName: 'Amount__c', sortable: true }
    ];

    /** The field to sort the data by */
    @track sortBy;

    /** The direction to sort the data */
    @track sortDir;

    /** Whether the Add button should be disabled */
    @track disableButton = true;

    /** Whether the current case is closed */
    caseNotClosed = true;

    /** The message context to subscribe and publish messages */
    @wire(MessageContext)
    messageContext;

    /**
     * Gets the configuration data for the current case and sets the `configData` property.
     */
    @wire(getConfigData, { recordId: '$recordId' })
    getConfigData({ data, error }) {
        if (data) {
            this.configData = data;
            this.handleGetCaseStatusValue();
        } else if (error) {
            this.handleToastMessage('ERROR', error, 'error');
        }
    }

    /**
     * Gets the case status value for the current case and sets the `caseNotClosed` property.
     */
    handleGetCaseStatusValue() {
        getCaseStatusValue({ recordId: this.recordId })
            .then(result => {
                this.caseNotClosed = result;
            })
            .catch(error => {
                this.handleToastMessage('ERROR', error, 'error');
            });
    }

    /**
     * Subscribes to the `Refresh_Case__c` message channel.
     */
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    /**
     * Sort the data.
     * @param {string} fieldname - The name of the field to sort by.
     * @param {string} direction - The sorting direction.
     */
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
    
    /**
     * Handle the sort event.
     * @param {object} event - The event object.
     */
    doSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDir = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDir);
    }
    
    /**
     * Handle the row selection action.
     * @param {object} event - The event object.
     */
    rowSelectionAction(event){
        const selectedRows = event.detail.selectedRows;
        if(selectedRows.length > 0 && this.caseNotClosed){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }
    
    /**
     * Handle the add button click.
     * @param {object} event - The event object.
     */
    handleClickAdd(event){
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        this.handleAddConfigData(selectedRecords);
    }

    /**
     * Invokes the Apex method to insert selected records into Case Configurations and updates the component UI and the parent component
     * @param {Array} selectedRecords - The selected records to be added to Case Configurations
     */
    handleAddConfigData(selectedRecords){
        addConfigData({recordId : this.recordId, newConfigRecs : selectedRecords})
        .then(result =>{
            if(result){
                this.handleToastMessage(SUCCESS_TITLE, 'Records Inserted Successfully' , SUCCESS_VARIANT);
                let clonedConfigData = this.configData;
                this.configData = this.removeElements(clonedConfigData, selectedRecords);
                this.refreshCaseRecord();
            }
        })
        .catch(error =>{
            this.handleToastMessage(ERROR_TITLE, error , ERROR_VARIANT);
        })
    }

    /**
     * Removes the elements from the configData array based on the currentSelectedRecords array
     * @param {Array} currentConfigRecs - The current configuration records array
     * @param {Array} currentSelectedRecords - The selected records array to be removed from the configData array
     * @returns {Array} - The updated configData array with the selected records removed
     */
    removeElements(currentConfigRecs, currentSelectedRecords){
        return currentConfigRecs.filter(currentConfigRec => {
            return !currentSelectedRecords.some(currentSelectedRec => currentConfigRec.Label__c === currentSelectedRec.Label__c);
        });
    }

    /**
     * Wire service to handle message context subscription
     */
    @wire(MessageContext)
    messageContext;

    /**
     * Publishes the refresh event to the parent component on successful record insert
     */
    refreshCaseRecord(){
        const caseData = {
            recordId: this.recordId,
            action: 'reload'
        }
        publish(this.messageContext, REFRESH_CASE, caseData);
    }

    /**
     * Displays the toast message with the specified title, message and variant
     * @param {String} title - The title of the toast message
     * @param {String} message - The message to be displayed in the toast
     * @param {String} variant - The variant of the toast message
     */
    handleToastMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    /**
     * Subscribes to the message channel to listen to refresh events
     */
    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          REFRESH_CASE,
          caseData => this.handleRefreshCaseEvent(caseData)
        );
    }

    /**
     * Handles the refresh event and disables the Add button if the Case is Closed
     * @param {Object} caseEventData - The data object of the refresh event
     */
    handleRefreshCaseEvent(caseEventData){
        if(caseEventData.recordId === this.recordId && caseEventData.action === 'disable'){
            this.disableButton = true;
            this.caseNotClosed = false;
        }
    }
}