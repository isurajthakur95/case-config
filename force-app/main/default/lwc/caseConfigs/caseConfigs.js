import { LightningElement, api, track, wire } from 'lwc';
import getCaseConfigData from '@salesforce/apex/CaseConfigController.getCaseConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import REFRESH_CASE from '@salesforce/messageChannel/Refresh_Case__c';
import actionOnConfigData from '@salesforce/apex/CaseConfigController.actionOnConfigData';

// Define constants for toast messages
const TOAST_ERROR_VARIANT = 'error';
const TOAST_ERROR_TITLE = 'ERROR';
const TOAST_SUCCESS_VARIANT = 'success';
const TOAST_SUCCESS_TITLE = 'SUCCESS';

/**
 * A component to display and edit case configuration data.
 * @extends LightningElement
 */
export default class CaseConfigs extends LightningElement {
    /** Public property ID of the case record. */
    @api recordId;

    /** The columns to display in the case configuration table. */
    columns = [
        { label: 'Label', fieldName: 'Label__c' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Amount', fieldName: 'Amount__c' }
    ];

    /** The case configuration data to display in the table. */
    @track caseConfigData = [];

    /** Indicates whether the "Send to Finance" button should be disabled. */
    @track disableButton = true;

    /**
     * Called when the component is connected to the DOM.
     * Retrieves the case configuration data and subscribes to the REFRESH_CASE message channel.
     */
    connectedCallback() {
        this.handleGetCaseConfigData(this.recordId);
        this.subscribeToMessageChannel();
    }

    /**
     * Retrieves the case configuration data for the given case record ID.
     * @param {string} recordId - The ID of the case record.
     */
    handleGetCaseConfigData(recordId) {
        getCaseConfigData({ recordId: recordId })
            .then(result => {
                if (result) {
                    this.caseConfigData = result;
                    if (result.length > 0 && result[0].Case__r.Status !== 'Closed') {
                        this.disableButton = false;
                    } else {
                        this.disableButton = true;
                    }
                }
            })
            .catch(error => {
                this.handleToastMessage(TOAST_ERROR_TITLE, error, TOAST_ERROR_VARIANT);
            });
    }

    /**
     * Called when the "Send to Finance" button is clicked.
     * Sends the case configuration data to the finance system and disables the button.
     * Also publishes a message to the REFRESH_CASE channel to disable the "Add Config" button on the case page.
     * @param {Event} event - The click event.
     */
    handleClickSend(event) {
        this.handleActionOnConfigData();
        this.disableButton = true;
        this.setDisableAddButton();
    }

    // Method to display toast messages
    handleToastMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    @wire(MessageContext)
    messageContext;
    
    // Subscribe to the message channel
    subscribeToMessageChannel() {
        try {
            this._subscription = subscribe(
              this.messageContext,
              REFRESH_CASE,
              caseData => this.handleReloadCaseConfigData(caseData)
            );
        } catch (error) {
            throw new Error('Error while subscribing to message channel: ' + error);
        }
    }

    // Handle reload case config data event
    handleReloadCaseConfigData(caseEventData){
        if(caseEventData.recordId === this.recordId && caseEventData.action === 'reload')
            this.handleGetCaseConfigData(caseEventData.recordId);
    }

    // Method to handle action on config data
    handleActionOnConfigData(){
        actionOnConfigData({recordId : this.recordId})
        .then(result =>{
            this.handleToastMessage(TOAST_SUCCESS_TITLE, 'Records Submitted Successfully' , TOAST_SUCCESS_VARIANT);
        })
        .catch(error =>{
            this.handleToastMessage(TOAST_ERROR_TITLE, error.body.message , TOAST_ERROR_VARIANT);
        })
    }

    // Method to publish message to disable add button
    setDisableAddButton(){
        const caseData = {
            recordId: this.recordId,
            action: 'disable'
        }
        publish(this.messageContext, REFRESH_CASE, caseData);
    }
}