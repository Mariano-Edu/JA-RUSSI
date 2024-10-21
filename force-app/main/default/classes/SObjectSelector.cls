public without sharing class SObjectSelector {
  public static List<SObject> buscarRegistrosPorIds(
    List<String> campos,
    String objectApiName,
    Set<Id> recordIds
  ) {
    String camposStr = campos.isEmpty() ? '' : ', ' + String.join(campos, ', ');

    return Database.queryWithBinds(
      'SELECT Id' +
        camposStr +
        ' FROM ' +
        objectApiName +
        ' WHERE Id IN :recordIds',
      new Map<String, Object>{ 'recordIds' => recordIds },
      System.AccessLevel.SYSTEM_MODE
    );
  }
}