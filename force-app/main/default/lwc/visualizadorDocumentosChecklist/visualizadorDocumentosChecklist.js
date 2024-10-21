import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import documentosPorAnaliseCredito from '@salesforce/apex/DocumentoController.documentosPorAnaliseCredito';
import buscarConfiguracoesDocumentosChecklist from '@salesforce/apex/DocumentosChecklistSelector.buscarConfiguracoesDocumentosChecklist'
import obterInfoContaPorAnaliseCredito from '@salesforce/apex/AccountController.obterInfoContaPorAnaliseCredito'
import obterDocumentoPorId from '@salesforce/apex/DocumentoSelector.obterDocumentoPorId'
import atualizarStatusDocumento from '@salesforce/apex/DocumentoController.atualizarStatusDocumento'
import buscarArquivosPorIdLinkedEntity from '@salesforce/apex/ManagerFilesController.buscarArquivosPorIdLinkedEntity'
import atualizarValoresConta from '@salesforce/apex/AccountController.atualizarValoresConta'
import adicionarObservacoesDocumento from '@salesforce/apex/DocumentoController.adicionarObservacoesDocumento'

export default class VisualizadorDocumentosChecklist extends LightningElement {
    @api recordId;
    @track contas = [];
    @track error;
    @track tipoDocValor = [];
    @track docSelecionado = false;
    @track labelValueDocSelecionado = [];
    @track selectDocInfo;
    @track urlVisuDocumento;
    @track arquivoImagem = false;
    @track campoObservacoes = false;
    @track areaContasVisivel = true;

    contasInfo = [];
    configDocsChecklist = [];
    contaSelecionada;

    iconesStatusDocumento = {
        'Não Entregue': '/resource/NaoEntregueIconResource',
        'Entregue': '/resource/EntregueIconResource',
        'Reprovado': '/resource/ReprovadoIconResource',
        'Em Análise': '/resource/EmAnaliseIconResource',
        'Vencido': '/resource/ReprovadoIconResource',
        'Aprovado': '/resource/AprovadoIconResource'
    }

    mudarAreaContasVisivel() {
        this.areaContasVisivel = !this.areaContasVisivel;
    }

    @wire(buscarConfiguracoesDocumentosChecklist)
    wiredConfigs({ data, error }) {
        if (error) {
            console.log(error);
        } else {
            this.configDocsChecklist = data;
        }
    }

    @wire(documentosPorAnaliseCredito, { idAnaliseCredito: '$recordId' })
    wiredDocumentos({ data, error }) {
        if (error) {
            console.log(error);
        } else {
            for (let comprador in data) {
                let documentosIdentificacao = [];
                let documentosVeiculo = [];
                let documentosImovel = [];

                for (let documento in data[comprador]) {
                    const documentoAtual = data[comprador][documento];

                    switch (documentoAtual.TipoDocumento__c) {
                        case 'Identificação':
                            documentosIdentificacao.push(documentoAtual)
                            break;
                    
                        case 'Veículo':
                            documentosVeiculo.push(documentoAtual)
                            break;
                    
                        case 'Imóvel':
                            documentosImovel.push(documentoAtual)
                            break;
                    }
                }

                this.contas.push({
                    id: data[comprador][0].Conta__c,
                    nome: comprador,
                    documentosIdentificacao: documentosIdentificacao,
                    documentosVeiculo: documentosVeiculo,
                    documentosImovel: documentosImovel
                })
            }
        }
    }

    @wire(obterInfoContaPorAnaliseCredito, { idAnaliseCredito: '$recordId' })
    wiredInfoContas({ data, error }) {
        if (error) {
            console.log(error);
        } else {
            this.contasInfo = data;
        }
    }

    selectDoc(e) {
        this.labelValueDocSelecionado = [];
        this.urlVisuDocumento = null;

        const dataset = e.currentTarget.dataset;

        obterDocumentoPorId({ idDocumento: dataset.iddoc }).then(docInfo => {
            this.selectDocInfo = docInfo

            this.configDocsChecklist.forEach(configDocChecklist => {
                if (configDocChecklist.TipoDocumento__c == dataset.tipodoc) {
                    this.labelValueDocSelecionado.push({
                        label: configDocChecklist.LabelCampo__c,
                        value: this.contasInfo[dataset.nomeconta][configDocChecklist.CampoConta__c],
                        campoConta: configDocChecklist.CampoConta__c
                    });
                }
            });

            buscarArquivosPorIdLinkedEntity({ idLinkedEntity: dataset.iddoc }).then(arquivos => {
                this.arquivoImagem = arquivos[0].urlDocumentoVisualizador.includes('ORIGINAL_Jpg');

                this.urlVisuDocumento = arquivos[0].urlDocumentoVisualizador;
            }).catch(e => {
                console.log(e);
            });

            this.docSelecionado = true;
            this.contaSelecionada = dataset.idconta;
        }).catch(e => {
            console.log(e);
        });
    }

    mudarStatusDoc(e) {
        const dataset = e.currentTarget.dataset;

        const mapIdDocPorStatus = {
            [dataset.iddoc]: dataset.status
        };

        this.selectDocInfo.StatusIcone__c = this.iconesStatusDocumento[dataset.status];

        atualizarStatusDocumento({ mapStatusPorIdDocumento: mapIdDocPorStatus }).then(() => {
            const iconeStatus = this.template.querySelector(`.iconeStatusDoc[data-iddoc=${dataset.iddoc}]`);

            iconeStatus.src = this.iconesStatusDocumento[dataset.status];

            this.dispararToast('Sucesso', 'Status de documento alterado com sucesso!', 'success');
        });
    }

    salvarDocumento() {
        let campoValorConta = {};
        const campos = this.template.querySelectorAll('.campo');

        for (let key in campos) {
            if (campos[key] instanceof HTMLElement) {
                let [campo, valor] = [campos[key].dataset.campoconta, campos[key].querySelector('lightning-input').value]

                if (this.verificarCampoAtualizado(campo, valor)) {
                    campoValorConta[campo] = valor;
                }
            }
        }

        if (Object.keys(campoValorConta).length > 0) {
            atualizarValoresConta({ camposValores: campoValorConta, idConta: this.contaSelecionada });
            this.dispararToast('Sucesso', 'Alterações aplicadas na conta!', 'success');
        }

        const observacoes = this.template.querySelector('.campo_observacoes');

        if (observacoes.value) {
            adicionarObservacoesDocumento({ idDocumento: observacoes.dataset.iddoc, observacoes: observacoes.value });
            this.dispararToast('Sucesso', 'Observações aplicadas em documento!', 'success');
        }
    }

    verificarCampoAtualizado(campo, valor) {
        let campoAtualizado = false;

        this.labelValueDocSelecionado.forEach(campoValor => {
            if (campoValor.campoConta == campo) {
                campoAtualizado = campoValor.value != valor;
            }
        })

        return campoAtualizado;
    }

    dispararToast(titulo, mensagem, variante) {
        this.dispatchEvent(new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante
        }));
    }
}