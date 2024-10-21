public class SObjectDomain {
  public static SObject obterRegistroPorId(
    List<String> campos,
    String objectApiName,
    Id idRegistro
  ) {
    List<SObject> registros = SObjectSelector.buscarRegistrosPorIds(
      campos,
      objectApiName,
      new Set<Id>{ idRegistro }
    );

    return registros.isEmpty() ? null : registros.get(0);
  }

  // public static Set<Id> obterIds(List<SObject> registros) {
  //   return (new Map<Id, SObject>(registros)).keySet();
  // }
}