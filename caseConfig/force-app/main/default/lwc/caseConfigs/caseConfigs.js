import { LightningElement , api , track , wire } from 'lwc';
import getCaseConfigData from '@salesforce/apex/CaseConfigController.getCaseConfigData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, MessageContext } from 'lightning/messageService';
import REFRESH_CASE from '@salesforce/messageChannel/Refresh_Case__c';

const columns = [
    { label: 'Label', fieldName: 'Label__c' },
    { label: 'Type', fieldName: 'Type__c' },
    { label: 'Amount', fieldName: 'Amount__c' }
];

const errorVariant = 'error';
const errorTitle = 'ERROR';
const successVariant = 'success';
const successTitle = 'SUCCESS';

export default class CaseConfigs extends LightningElement {
    @api recordId;
    columns = columns;
    @track caseConfigData = [];
    @track disableButton = true;

    connectedCallback(){
        this.handleGetCaseConfigData(this.recordId);
        this.subscribeToMessageChannel();
    }

    handleGetCaseConfigData(recordId){
        getCaseConfigData({recordId : recordId})
        .then(result =>{
            if(result){
                this.caseConfigData = result;
            }
        })
        .catch(error =>{
            this.handleToastMessage(errorTitle, error , errorVariant);
        })
    }

    handleClickSend(event){
    }

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

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          REFRESH_CASE,
          caseData => this.handleGetCaseConfigData(caseData.recordId)
        );
    }
}