public with sharing class UtilityMethods {
  public UtilityMethods() {
  }

  //Field set Related
  public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String objectName) {
      Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe().get(objectName).getDescribe(); 
      Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
      System.Debug(fieldSetObj);
      return fieldSetObj.getFields(); 
  }

  public static string getFieldSetMemberAPINames(String fieldSetName, String objectName) {
    String fieldAPINames = ' ';
    for(Schema.FieldSetMember fsm: readFieldSet(fieldSetName, objectName))
      fieldAPINames += ', ' + fsm.getFieldPath();
    return fieldAPINames;
  }
  public static List<string> getFieldSetMemberAPINamesList(String fieldSetName, String objectName) {
    List<String> fieldAPINames = new List<String>();
    for(Schema.FieldSetMember fsm: readFieldSet(fieldSetName, objectName))
      fieldAPINames.add(fsm.getFieldPath());
    return fieldAPINames;
  }

  public static Map<String, String> getFieldLabelMap(String fieldSetName, String objectName) {
    Map<String, String> fieldLabelMap = new Map<String, String>();
    for(Schema.FieldSetMember fsm: readFieldSet(fieldSetName, objectName))
      fieldLabelMap.put(objectName+fsm.getFieldPath(), fsm.getLabel());
    return fieldLabelMap;
  }

  public class FieldSetWrapper {
      @AuraEnabled public String fieldName { get;set; }
      @AuraEnabled public String label { get;set; }
      @AuraEnabled public String type { get; set; }
      public FieldSetWrapper(Schema.FieldSetMember f) {
          this.fieldName = f.fieldPath;
          this.label = f.label;
          this.type = (f.getType()+''=='double'?'number':
                       (f.getType()+''=='PICKLIST'?'text':
                       ''+f.getType()));
      } }
    @AuraEnabled
    public static List<FieldSetWrapper> buildFSWList(String fieldSetName, String objectName) {
      List<FieldSetWrapper> fswList = new List<FieldSetWrapper>();
    for(Schema.FieldSetMember fsm: readFieldSet(fieldSetName, objectName))
      fswList.add(new FieldSetWrapper(fsm));
    return fswList;
    }

    public static Set<String> getFormulaFields(String fieldSetName, String objectName) {
      Set<String> formulaFields = new Set<String>();
      
      Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);

      List<Schema.FieldSetMember> listFSM = readFieldSet(fieldSetName, objectName);
      for(Schema.FieldSetMember fsm: listFSM)
        if( sObj.getDescribe().fields.getMap().get(fsm.getFieldPath()).getDescribe().isCalculated())
          formulaFields.add(fsm.getFieldPath());
      

      return formulaFields; 
  }

  public class PicklistSelectOption {
      @AuraEnabled public String label { get;set; }
      @AuraEnabled public String value { get;set; }
      public PicklistSelectOption(SelectOption so) {
          this.label = so.getLabel();
          this.value = so.getValue();
      } }
  public static List<PicklistSelectOption> getPicklistOptions(String fieldName, String objectName) {
    List<PicklistSelectOption> options = new List<PicklistSelectOption>();
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
    List<Schema.PicklistEntry> picklistvalues = fieldMap.get(fieldName).getDescribe().getPickListValues();
    for (Schema.PicklistEntry a : picklistvalues) { //for all values in the picklist list
        options.add(new PicklistSelectOption(new SelectOption(a.getValue(), a.getLabel())));
    }
    return options;
  }
}