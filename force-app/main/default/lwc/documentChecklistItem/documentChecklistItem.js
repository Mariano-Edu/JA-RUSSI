import { LightningElement, wire, api } from 'lwc';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_DOCUMENTO_CHECKLIST from "@salesforce/schema/DocumentoChecklist__c.Id";
import STATUS_DOCUMENTO_CHECKLIST from "@salesforce/schema/DocumentoChecklist__c.Status__c";
import JUSTIFICATIVA_DOCUMENTO_CHECKLIST from "@salesforce/schema/DocumentoChecklist__c.JustificativaDeReprovacao__c";
import uploadFile from '@salesforce/apex/ContentDocumentController.uploadFile';

export default class DocumentChecklistItem extends NavigationMixin(LightningElement) {
    @api docCheckId  
    @api docCheckStatus
    @api docCheckObrigatorio  
    @api docCheckName
    @api contentDocumentId
    isShowModal = false
    
    isShowButtonAprovar = false
    isShowButtonReprovar = false
    justificativaValue
    uploadMessage

    connectedCallback(){
        this.refreshGet()
    }

    handleButtonAprovar(){
        this.updateDocumentoChecklistStatus(this.docCheckId, 'Aprovado');
    }
    handleButtonReprovar(){
        this.showModalBox();
    }
    
    handleUploadButton() {
        const fileUpload = this.template.querySelector('[data-id="hiddenFileUpload"]');
        
        if (fileUpload) {
            fileUpload.click();
        }
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        
        if (file) {
            const fileName = file.name;
            const fileType = file.type;
            const fileSize = file.size;
            
            const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
            
            
            try {
                if (this.isValidFileType(fileType)) {
                    if (fileSize <= maxSizeInBytes) {
                        const reader = new FileReader();
                        reader.onload = () => {
                            const base64 = reader.result.split(',')[1];
                            this.handleUploadFile(base64, fileName, fileType)
                        };
                        reader.readAsDataURL(file);
                    } else {
                        console.error('O arquivo é muito grande.');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Erro',
                                message: 'O arquivo é muito grande. O tamanho máximo permitido é 5 MB.',
                                variant: 'error',
                            })
                        );
                    }
                } else {
                    console.error('Tipo de arquivo não suportado.');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erro',
                            message: 'Tipo de arquivo não suportado. Apenas JPG, PNG e PDF são aceitos.',
                            variant: 'error',
                        })
                    );
                }
            } catch (error) {
                
                console.log(error);
            }
        }
    }
    
    handleUploadFile(base64, fileName, fileType){
        uploadFile({ base64:base64,fileName: fileName,linkEntityId: this.docCheckId,fileType:fileType}) 
        .then(result => {
            this.uploadMessage = 'Documento enviado com sucesso!'
            
            if(this.contentDocumentId != null) {
                this.uploadMessage = 'Documento substituído com sucesso!'
            }
            this.contentDocumentId = result 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso',
                    message: this.uploadMessage,
                    variant: 'success',
                })
            );
            this.updateDocumentoChecklistStatus(this.docCheckId, 'Entregue');

            
        })
        
    }
    
    isValidFileType(fileType) {
        const validFileTypes = ['image/jpeg', 'image/png', 'application/pdf'];
        
        return validFileTypes.includes(fileType);
    }
    
    updateDocumentoChecklistStatus(documentoChecklistId, newStatus){
        const fields = {};
        fields[ID_DOCUMENTO_CHECKLIST.fieldApiName] = documentoChecklistId;
        fields[STATUS_DOCUMENTO_CHECKLIST.fieldApiName] = newStatus;
        const recordInput = { fields: fields };
        updateRecord(recordInput)
        .then(() => {
            console.log('success');
        })
        .catch(error => {
            console.log('error');
        });
        this.docCheckStatus = newStatus
        this.refreshGet()
    }
    
    updateJustificativaReprovacao(justificativa) {
        const fields = {};
        fields[ID_DOCUMENTO_CHECKLIST.fieldApiName] = documentoChecklistId;
        fields[JUSTIFICATIVA_DOCUMENTO_CHECKLIST.fieldApiName] = justificativa;
        const recordInput = { fields: fields };
        updateRecord(recordInput)
        .then(() => {
            console.log('success');
        })
        .catch(error => {
            console.log('error');
        });
    }
    
    handleButtonView(){
        this.filePreview();
    }   
    handleButtonDelete(){
        this.deleteFile();
    }
    
    deleteFile(){
        deleteRecord(this.contentDocumentId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Documento deletado com Sucesso!',
                    variant: 'success'
                })
            );
            this.contentDocumentId = null;
            this.updateDocumentoChecklistStatus(this.docCheckId, 'Pendente');
        })
        .catch((error) => {
            console.log(error);
        });
    }
    
    filePreview() {
        
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: this.contentDocumentId
            }
        });
    }
    
    handleReprovarConfirmButton(){
        if(this.justificativaText == ''){
            this.showAlertError('A justificativa é obrigatória')
            return;
        }
        this.updateDocumentoChecklistStatus(this.docCheckId, 'Reprovado');
        this.hideModalBox();
        this.justificativaText = '';
    }

    showAlertError(message){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Erro',
                message: message,
                variant: 'error',
            })
        );
    }
    
    showModalBox() {  
        this.isShowModal = true;
    }
    
    hideModalBox() {  
        this.isShowModal = false;
    }
    
    refreshGet(){
        this.showAprovar()
        this.showReprovar()
    }

    showAprovar() {
        console.log('showaprovar');
        console.log(this.docCheckStatus == 'Entregue');


        if(this.docCheckStatus == 'Entregue'){
            this.isShowButtonAprovar = true;
        } else {

            this.isShowButtonAprovar = false;
        }
    }
    showReprovar() {
        console.log('showreprovar');
        console.log(this.docCheckStatus == 'Entregue');
        
        if(this.docCheckStatus == 'Entregue'){
            this.isShowButtonReprovar = true;
        } else {

            this.isShowButtonReprovar = false;
        }
    }
}