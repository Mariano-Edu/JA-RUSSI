import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import LabelEndereco from "@salesforce/label/c.Endereco";
import PesquisarEndereco from "@salesforce/label/c.PesquisarEndereco";
import Salvar from "@salesforce/label/c.Salvar";
import Erro from "@salesforce/label/c.Erro";
import Atencao from "@salesforce/label/c.Atencao";
import MensagemTamanhoCEP from "@salesforce/label/c.MensagemTamanhoCEP";
import Sucesso from "@salesforce/label/c.Sucesso";
import MensagemEnderecoModificado from "@salesforce/label/c.MensagemEnderecoModificado";

import buscarEndereco from "@salesforce/apex/EnderecoController.buscarEndereco";
import modificarEndereco from "@salesforce/apex/EnderecoController.modificarEndereco";
import obterRegistro from "@salesforce/apex/EnderecoController.obterRegistro";

export default class Endereco extends LightningElement {
  @api recordId;
  @api objectApiName;
  // Campos escolhidos pelo usuário para atualização no componente do registro.
  @api campoLogradouro;
  @api campoCidade;
  @api campoUF;
  @api campoPais;
  @api campoCEP;
  @api campoNumero;
  @api campoComplemento;
  @api campoBairro;
  @api apresentarValores;
  @api apresentarBotaoSalvar;

  // Adicionar novos campos que vierem da integração neste objeto para exibição.
  @track endereco = {
    logradouro: "",
    numero: "",
    complemento: "",
    bairro: "",
    localidade: "",
    uf: "",
    pais: "",
    cep: ""
  };
  // Campos que vem da integração porém devem estar liberados para edição caso vierem em branco.
  @track naoPreenchidos = {
    logradouro: "",
    bairro: "",
    localidade: "",
    uf: ""
  };

  carregando = false;
  cep = null;

  label = {
    LabelEndereco,
    PesquisarEndereco,
    Salvar,
    Erro,
    Atencao,
    MensagemTamanhoCEP,
    Sucesso,
    MensagemEnderecoModificado
  };

  /**
   * Campos para exibição de mapa após carregamento do endereço.
   */
  get mapMarkers() {
    return [
      {
        location: {
          City: this.valorLocalidade,
          Country: this.endereco.pais,
          PostalCode: this.endereco.cep,
          State: this.valorUF,
          Street: this.enderecoFormatado,
          Number: this.endereco.numero
        }
      }
    ];
  }

  get apresentarMapa() {
    return (
      this.enderecoFormatado &&
      this.valorLocalidade &&
      this.valorUF &&
      this.endereco.pais
    );
  }

  /**
   * Valores para abertura de campos para edição que podem não ser carregados
   * pela integração.
   */
  get valorLogradouro() {
    return !this.desabilitarLogradouro
      ? this.naoPreenchidos.logradouro
      : this.endereco.logradouro;
  }

  get valorBairro() {
    return !this.desabilitarBairro
      ? this.naoPreenchidos.bairro
      : this.endereco.bairro;
  }

  get valorLocalidade() {
    return !this.desabilitarLocalidade
      ? this.naoPreenchidos.localidade
      : this.endereco.localidade;
  }

  get valorUF() {
    return !this.desabilitarUF ? this.naoPreenchidos.uf : this.endereco.uf;
  }

  /**
   * Endereço para apresentação do mapa após carregamento.
   */
  get enderecoFormatado() {
    return `${this.valorLogradouro} ${this.endereco.complemento ? " - " + this.endereco.complemento : ""}, ${this.valorBairro}`;
  }

  /**
   * Os campos só podem ser exibidos após salvamento caso a apresentação
   * de valores tenha sido marcada pelo usuário.
   */
  get podeExibirCampos() {
    return this.apresentarValores || this.consultaRealizada;
  }

  /**
   * O salvamento só pode ser realizado caso a apresentação do botão tenha
   * sido marcada pelo usuário.
   */
  get podeSalvar() {
    return this.apresentarBotaoSalvar && this.consultaRealizada;
  }

  /**
   * Habilitação de campos não preenchidos pela integração.
   */
  get desabilitarLogradouro() {
    return Boolean(this.endereco.logradouro);
  }

  get desabilitarBairro() {
    return Boolean(this.endereco.bairro);
  }

  get desabilitarLocalidade() {
    return Boolean(this.endereco.localidade);
  }

  get desabilitarUF() {
    return Boolean(this.endereco.uf);
  }

  /**
   * Novos campos que forem configurados devem ser adicionados a este
   * get.
   */
  get campos() {
    return [
      this.campoLogradouro,
      this.campoComplemento,
      this.campoBairro,
      this.campoCidade,
      this.campoUF,
      this.campoPais,
      this.campoCEP,
      this.campoNumero
    ].filter((campo) => Boolean(campo));
  }

  /**
   * Caso a apresentação de valores tenha sido escolhida pelo usuário,
   * são carregados os valores do registro em tela.
   */
  connectedCallback() {
    if (this.apresentarValores) {
      this.handleObterRegistro();
    }
  }

  /**
   * Método responsável pela obtenção do registro em tela para exibição
   * dos campos configurados.
   */
  async handleObterRegistro() {
    this.carregando = true;

    try {
      const registro = await this.obterRegistro(
        this.campos,
        this.objectApiName,
        this.recordId
      );

      this.mapearCamposEndereco(registro);
    } catch (erro) {
      this.carregando = false;

      this.apresentarMensagem(this.label.Erro, erro, "error");
    }

    this.carregando = false;
  }

  /**
   * Método responsável pelo mapeamento de campos do registro para campos
   * exibidos em tela. Novos campos devem ser adicionados neste método.
   */
  mapearCamposEndereco(registro) {
    this.endereco = {
      logradouro: registro[this.campoLogradouro],
      numero: registro[this.campoNumero],
      complemento: registro[this.campoComplemento],
      bairro: registro[this.campoBairro],
      localidade: registro[this.campoCidade],
      uf: registro[this.campoUF],
      pais: registro[this.campoPais],
      cep: registro[this.campoCEP]
    };
  }

  async obterRegistro(campos, objectApiName, recordId) {
    return new Promise((resolve, reject) =>
      obterRegistro({ campos, objectApiName, recordId })
        .then((resultado) => resolve(JSON.parse(resultado)))
        .catch((erro) => reject(erro))
    );
  }

  handleCEP(event) {
    this.cep = event.target.value;
  }

    /**
     * Método executado ao pressionar 'enter' em campo de pesquisa de CEP ou 
     * clicar no botão procurar para a obtenção de endereço via integração.
     */
    async handleBuscarEndereco(event) {
        if (event.keyCode !== 13 && event.type !== "click") { return; }
        if (!this.cepValido()) { return; }

        this.carregando = true;
        try {
          const endereco = await buscarEndereco({ cep: this.cep });
          this.endereco = this.obterEnderecoFormatado(JSON.parse(endereco));
          this.cep = null;
          this.consultaRealizada = true;
        } catch (erro) {
          this.apresentarMensagem(this.label.Erro, erro.body.message || erro.message, 'error');
        }
        this.carregando = false;
    }

    /**
     * Preenchimento fixo de país como 'BR'.
     */
    obterEnderecoFormatado(endereco) {
        return { ...endereco, pais: 'BR' };
    }

    cepValido() {
        return this.cepTemComprimentoCorreto();
    }

    cepTemComprimentoCorreto() {
        if (this.cep && this.cep.length === 8) { return true; }
        this.apresentarMensagem(this.label.Atencao, this.label.MensagemTamanhoCEP, 'warning');
        return false;
    }

  /**
   * Método responsável pela atualização de campos não carregados pela integração
   * ('número') e outros que vieram em branco.
   */
  handleInputChange(event) {
    this.consultaRealizada = true;

    switch (event.target.dataset.name) {
      case "numero":
      case "complemento":
        this.endereco[event.target.dataset.name] = event.target.value;

        break;
      default:
        this.naoPreenchidos[event.target.dataset.name] = event.target.value;

        break;
    }
  }

  async handleModificarEndereco(event) {
    event.preventDefault();
    this.carregando = true;

    try {
        const registroAtualizado = this.obterRegistroAtualizado();
        await modificarEndereco({
            enderecoJSON: JSON.stringify(registroAtualizado),
            objectApiName: this.objectApiName,
            recordId: this.recordId
        });
        this.endereco.numero = '';
        this.endereco.complemento = '';
        this.apresentarMensagem(this.label.Sucesso, this.label.MensagemEnderecoModificado, 'success');
        getRecordNotifyChange([{ recordId: this.recordId }]);
        setTimeout(() => {
            window.location.reload();
        }, 1000);
        this.consultaRealizada = false;
    } catch (erro) {
        this.apresentarMensagem(this.label.Erro, erro.body.message || erro.message, 'error');
    }
    this.carregando = false;
}

  async modificarEndereco(enderecoJSON, objectApiName, recordId) {
    return new Promise((resolve, reject) =>
      modificarEndereco({ enderecoJSON, objectApiName, recordId })
        .then((resultado) => resolve(resultado))
        .catch((erro) => reject(erro))
    );
  }

  /**
   * Método responsável pela atualização do registro com valores inseridos
   * pelo usuário. Novos campos devem ser adicionados a este método.
   */
  obterRegistroAtualizado() {
    const registro = {};

    if (this.campoLogradouro) {
      registro[this.campoLogradouro] = this.valorLogradouro;
    }
    if (this.campoCidade) {
      registro[this.campoCidade] = this.valorLocalidade;
    }
    if (this.campoUF) {
      registro[this.campoUF] = this.valorUF;
    }
    if (this.campoPais) {
      registro[this.campoPais] = this.endereco.pais;
    }
    if (this.campoCEP) {
      registro[this.campoCEP] = this.endereco.cep;
    }
    if (this.campoNumero) {
      registro[this.campoNumero] = this.endereco.numero;
    }
    if (this.campoComplemento) {
      registro[this.campoComplemento] = this.endereco.complemento;
    }
    if (this.campoBairro) {
      registro[this.campoBairro] = this.valorBairro;
    }

    return registro;
  }

  apresentarMensagem(titulo, mensagem, tipo) {
    const eventoToast = new ShowToastEvent({
      title: titulo,
      message: mensagem,
      variant: tipo
    });

    this.dispatchEvent(eventoToast);
  }
}