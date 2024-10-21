public class ViaCEPCallout extends RestCallout {
  private ViaCEPCallout(Map<String, Object> callout) {
    super(callout);
  }

  public static HttpResponse buscarEndereco(String cep) {
    return (new ViaCEPCallout(
        new Map<String, Object>{
          'endpoint' => 'https://viacep.com.br/ws/' +
          cep +
          '/json/',
          'method' => 'GET',
          'header' => new Map<String, String>{
            'Content-Type' => 'application/json'
          }
        }
      ))
      .send();
  }
}