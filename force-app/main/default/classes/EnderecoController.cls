public class EnderecoController {
  /**
   * Método responsável pela busca de endereço a partir de CEP para consulta
   * em ViaCEP.
   */
  @AuraEnabled
  public static String buscarEndereco(String cep) {
    return EnderecoService.buscarEndereco(cep);
  }

  /**
   * Método responsável pela atualização dos campos de endereço definidos para
   * um registro genérico. Os campos e valores atualizados são recebidos em
   * "enderecoJSON".
   */
  @AuraEnabled
  public static void modificarEndereco(
    String enderecoJSON,
    String objectApiName,
    Id recordId
  ) {
    EnderecoService.modificarEndereco(enderecoJSON, objectApiName, recordId);
  }

  @AuraEnabled
  public static String obterRegistro(
    List<String> campos,
    String objectApiName,
    Id recordId
  ) {
    return EnderecoService.obterRegistro(campos, objectApiName, recordId);
  }
}