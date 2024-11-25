import { LightningElement, api, wire } from 'lwc';

import getDocumentList from '@salesforce/apex/ViewMinutaDocumentController.getDocumentList';
import {refreshApex} from '@salesforce/apex';


export default class DocumentViewerById extends LightningElement {
    @api recordId;
    @api fileId;
    @api heightInRem;
    @wire(getDocumentList, { recordId: '$recordId' }) documents;

    get pdfHeight() {
        return '40rem';
    }
    get url() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }

    get getOptions() {
        console.log('this.documents.data =>' + this.documents.data)
        return this.documents.data;
    }

    handleChange(event) {
        console.log('event.detail.value =>' + event.detail.value)
        this.fileId = event.detail.value;
    }

    handleRefreshButton(){
        refreshApex(this.documents);
    }
}