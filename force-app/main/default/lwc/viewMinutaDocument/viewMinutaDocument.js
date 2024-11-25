import { LightningElement, api, wire } from 'lwc';

import getDocumentList from '@salesforce/apex/ViewMinutaDocumentController.getDocumentList';


export default class ViewMinutaDocument extends LightningElement {
    @api recordId;
    @api fileId;
    @api heightInRem;
    @wire(getDocumentList, { recordId: '$recordId' }) documents;

    get pdfHeight() {
        return this.heightInRem + 'rem';
    }
    get url() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }

    get getOptions() {
        console.log('this.documents.data =>' + JSON.stringify(this.documents.data));
        return this.documents.data;
    }

    handleChange(event) {
        console.log('event.detail.value =>' + event.detail.value)
        this.fileId = event.detail.value;
    }
}