import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import carregarArquivo from '@salesforce/apex/ContentDocumentLinkService.carregarArquivo';
import obterLinksDocumentosPorLinkedEntityId from '@salesforce/apex/ContentDocumentLinkSelector.obterLinksDocumentosPorLinkedEntityId';

export default class ChecklistDocumentos extends NavigationMixin(LightningElement) {
    @api documentos;
    @api uploadedfiles = {};
    @api mapContentDocument;
    
    redirecionarPaginaDocumento(event) {
        window.location = `${window.location.origin}/lightning/r/Documento__c/${event.target.dataset.iddoc}/view`
    }

    clickAnexoHandler(event) {
        this.template.querySelector(`input[data-iddoc=${event.target.dataset.iddoc}]`).click();
    }

    handleDelete(event) {
        const index = this.documentos.findIndex(doc => doc.Id === event.target.dataset.iddoc);
        if (index !== -1) {
            const documentosAtualizados = [...this.documentos];
            documentosAtualizados[index] = {
                ...documentosAtualizados[index],
                isLoading: true
            };
            this.documentos = documentosAtualizados;
        }

        obterLinksDocumentosPorLinkedEntityId({ linkedEntityId: event.target.dataset.iddoc })
            .then(res => {
                if (res.length === 0) return;

                const selectedRecordId = res[0].ContentDocumentId;
                deleteRecord(selectedRecordId)
                    .then(() => {
                        this.template.querySelector(`input[data-iddoc=${event.target.dataset.iddoc}]`).value = '';

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Sucesso',
                                message: 'Arquivo deletado',
                                variant: 'success'
                            })
                        );
                        this.dispatchEvent(new CustomEvent('atualizarchecklist'));
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Erro ao excluir arquivo',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
                });
    }

    previewHandler(event) {
        obterLinksDocumentosPorLinkedEntityId({ linkedEntityId: event.target.dataset.iddoc })
            .then(res => {
                if (res.length === 0) return;

                const selectedRecordId = res[0].ContentDocumentId;

                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        selectedRecordId
                    }
                });
            });
    }

    openfileUpload(event) {
        const file = event.target.files[0];
        const idDocumento = event.target.dataset.iddoc;
        const reader = new FileReader();
        
        if (!file) return;

        const fileType = file.type;
        const fileSize = file.size;
        const maxSizeInBytes = 2 * 1024 * 1024;

        if (fileSize > maxSizeInBytes) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'O arquivo é muito grande. O tamanho máximo permitido é 2 MB.',
                    variant: 'error',
                })
            );

            return;
        }

        if (!this.isValidFileType(fileType)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Tipo de arquivo não suportado. Apenas JPG, PNG e PDF são aceitos.',
                    variant: 'error',
                })
            );

            return;
        }

        reader.onload = () => {
            const readerBase64 = reader.result.split(',')[1];

            const index = this.documentos.findIndex(doc => doc.Id === idDocumento);
            if (index !== -1) {
                const documentosAtualizados = [...this.documentos];
                documentosAtualizados[index] = {
                    ...documentosAtualizados[index],
                    isLoading: true
                };
                this.documentos = documentosAtualizados;
            }
            
            carregarArquivo({ base64: readerBase64, filename: file.name, recordId: idDocumento, extensao: file.type.split('/')[1] })
                .then(result => {
                    if (result && !result.includes('Erro')) {
                        this.toast(`${file.name} carregado com sucesso!`);
                        this.uploadedfiles[idDocumento] = true;

                        const iconClassList = this.template.querySelector(`lightning-icon[data-iddoc=${idDocumento}]`).classList;
                        iconClassList.remove(iconClassList[0]);
                        iconClassList.add('Entregue');
                    } else {
                        this.toast(result, 'error');
                    }
                })
                .catch(error => {
                    console.log(`Erro ao carregar arquivo: ${JSON.stringify(error)}`);
                })
                .finally(() => {
                    this.dispatchEvent(new CustomEvent('atualizarchecklist'));
                });
        };

        reader.readAsDataURL(file);
    }

    toast(title, variant = 'success') {
        const toastEvent = new ShowToastEvent({
            title,
            variant
        });

        this.dispatchEvent(toastEvent);
    }

    isValidFileType(fileType) {
        const validFileTypes = ['image/jpeg', 'image/png', 'application/pdf'];
        
        return validFileTypes.includes(fileType);
    }
}