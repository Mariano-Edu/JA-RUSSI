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
        const idDocumento = event.target.dataset.iddoc;
        this.setDocumentoCarregando(idDocumento, true);

        obterLinksDocumentosPorLinkedEntityId({ linkedEntityId: idDocumento })
            .then(res => {
                if (res.length === 0) return;

                const selectedRecordId = res[0].ContentDocumentId;
                deleteRecord(selectedRecordId)
                    .then(() => {
                        this.template.querySelector(`input[data-iddoc=${idDocumento}]`).value = '';

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

            this.setDocumentoCarregando(idDocumento, true);
            
            carregarArquivo({ base64: readerBase64, filename: file.name, recordId: idDocumento, extensao: file.type.split('/')[1] })
                .then(result => {
                    if (result && !result.includes('Erro')) {
                        this.toast(`${file.name} carregado com sucesso!`);
                        this.documentos[this.documentos.findIndex(doc => doc.Id === idDocumento)].isUploaded = true;
                        this.dispatchEvent(new CustomEvent('atualizarchecklist'));
                    } else {
                        this.toast(result, 'error');
                    }
                })
                .catch(error => {
                    console.log(`Erro ao carregar arquivo: ${JSON.stringify(error)}`);
                })
                .finally(() => {
                    this.setDocumentoCarregando(idDocumento, false);
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

    setDocumentoCarregando(idDocumento, isLoading) {
        const index = this.documentos.findIndex(doc => doc.Id === idDocumento);

        const documentosAtualizados = [...this.documentos];
        documentosAtualizados[index] = {
            ...documentosAtualizados[index],
            isLoading: isLoading
        };

        this.documentos = documentosAtualizados;
    }
}