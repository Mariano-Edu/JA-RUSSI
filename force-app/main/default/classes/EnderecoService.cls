public without sharing class EnderecoService {    
  /**
   * Método responsável pela busca de endereço a partir de CEP para consulta
   * em ViaCEP.
   */
  public static String buscarEndereco(String cep) {
      HttpResponse response = ViaCEPCallout.buscarEndereco(cep);

      if (response.getStatusCode() != 200) {
          throw new CalloutException(String.format(System.Label.ErroConsultarCEP, new List<String>{ response.getStatus(), String.valueOf(response.getStatusCode()) }));
      }

      return response.getBody();
  }    
  
      /**
 * Método sobrescrito para visualização em Flows, responsável pela busca de endereço a
 * partir de CEP para consulta em ViaCEP.
 */ 
    @InvocableMethod(label='Buscar Endereço' description='Busca endereço pelo CEP')
    public static List<EnderecoResponse> buscarEnderecoInvocable(List<EnderecoRequest> requests) {
      List<EnderecoResponse> responses = new List<EnderecoResponse>();
      for (EnderecoRequest request : requests) {
      String enderecoJSON = buscarEndereco(request.cep);
      Map<String, Object> enderecoMap = (Map<String, Object>) JSON.deserializeUntyped(enderecoJSON);
    
      EnderecoResponse response = new EnderecoResponse();
      response.logradouro = (String) enderecoMap.get('logradouro');
      response.complemento = (String) enderecoMap.get('complemento');
      response.bairro = (String) enderecoMap.get('bairro');
      response.pais = 'BR';
      response.uf = (String) enderecoMap.get('uf');
      response.cep = (String) enderecoMap.get('cep');
      response.cidade = (String) enderecoMap.get('localidade');
    
      responses.add(response);
    }
    return responses;
  }
  // Classe auxiliar para a entrada
  public class EnderecoRequest {
    @InvocableVariable(required=true)
    public String cep;
  }

  // Classe auxiliar para a saída
  public class EnderecoResponse {
    @InvocableVariable
    public String logradouro;
  
    @InvocableVariable
    public String complemento;

    @InvocableVariable
    public String bairro;

    @InvocableVariable
    public String pais;

    @InvocableVariable
    public String uf;

    @InvocableVariable
    public String cep;
  
    @InvocableVariable
    public String cidade;
  }
  
  /**
   * Método responsável pela atualização dos campos de endereço definidos para
   * um registro genérico. Os campos e valores atualizados são recebidos em 
   * "enderecoJSON".
   */
  public static void modificarEndereco(String enderecoJSON, String objectApiName, Id recordId) {
      Map<String, Object> endereco = (Map<String, Object>) JSON.deserializeUntyped(enderecoJSON);
      SObject registro = SObjectDomain.obterRegistroPorId(new List<String>(endereco.keySet()), objectApiName, recordId);

      if (!atualizarRegistro(registro, endereco)) { return; }

      update registro;
  }

  /**
   * Apenas campos alterados são considerados na atualização.
   */
  private static Boolean atualizarRegistro(SObject registro, Map<String, Object> endereco) {
      Boolean atualizado = false;
      for(String campo : endereco.keySet()) {
          if(registro.get(campo) == endereco.get(campo)) {
              continue;
          }

          registro.put(campo, endereco.get(campo));

          atualizado = true;
      }

      return atualizado;
  }

  public static String obterRegistro(List<String> campos, String objectApiName, Id recordId) {
      SObject registro = SObjectDomain.obterRegistroPorId(campos, objectApiName, recordId);

      return JSON.serialize(registro);
  }
}