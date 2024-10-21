import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import documentosPorCompradorEmOportunidade from '@salesforce/apex/DocumentoController.documentosPorCompradorEmOportunidade';
import buscarConfiguracoesDocumentosChecklist from '@salesforce/apex/DocumentosChecklistSelector.buscarConfiguracoesDocumentosChecklist';
import obterLinksPorDocumentos from '@salesforce/apex/ContentDocumentLinkController.obterLinksPorDocumentos';

export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    @track contas = [];
    @track uploadedFiles = {};
    @track activeSections = ['Identificação', 'Imóvel', 'Veículo'];
    @track activeAccSections = [];
    @api isLoading = false;
    wiredDocumentosResult;

    connectedCallback() {
        this.isLoading = true;
    }

    handleAtualizarChecklist() {
        return refreshApex(this.wiredDocumentosResult)
            .catch((error) => { console.error('Erro ao atualizar documentos:', error) });
    }

    @wire(documentosPorCompradorEmOportunidade, { idOportunidade: '$recordId' })
    async wiredDocumentos(result) {
        this.wiredDocumentosResult = result;
        if (result.error) {
            console.error(`Erro ao buscar documentos da oportunidade: ${JSON.stringify(result.error)}`);
        } else if (result.data) {
            await this.processarDados(result.data);
        }
    }

    async processarDados(data) {
        this.contasClone = [];
        this.uploadedFiles = {};
        this.activeAccSections = [];
        this.nomes = Array.from(Object.keys(data));

        for (let comprador in data) {
            let documentosIdentificacao = [];
            let documentosVeiculo = [];
            let documentosImovel = [];
            this.activeAccSections.push(data[comprador]);

            try {
                const links = await obterLinksPorDocumentos({ documentos: data[comprador] });
                
                for (let docId in links) {
                    this.uploadedFiles[docId] = links[docId];
                }

                for (let documento in data[comprador]) {
                    const documentoAtual = data[comprador][documento];
                    const isUploaded = this.uploadedFiles[documentoAtual.Id] ? true : false;

                    const documentoProcessado = {
                        ...documentoAtual,
                        isUploaded
                    };

                    switch (documentoAtual.TipoDocumento__c) {
                        case 'Identificação':
                            documentosIdentificacao.push(documentoProcessado);
                            break;
                        case 'Veículo':
                            documentosVeiculo.push(documentoProcessado);
                            break;
                        case 'Imóvel':
                            documentosImovel.push(documentoProcessado);
                            break;
                    }
                }

                this.contasClone.push({
                    nome: comprador,
                    documentosIdentificacao,
                    documentosVeiculo,
                    documentosImovel
                });

            } catch (error) {
                console.error(`Erro ao processar dados para ${comprador}:`, error);
            }
        }

        this.contas = [...this.contasClone];
        this.activeSections.push(...this.nomes);
        this.isLoading = false;
    }

    @wire(buscarConfiguracoesDocumentosChecklist)
    wiredConfigs({ data, error }) {
        if (error) {
            console.log(`Erro ao buscar metadado de documentos da checklist: ${error}`);
        } else {
            this.configDocsChecklist = data;
        }
    }
}