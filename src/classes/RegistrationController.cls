public class RegistrationController {

        public RegistrationController(ApexPages.StandardController controller) {
                cont = (Contact)controller.getRecord();
        }

    public Map<String, String> displayLabelMap {
        get {
            if(displayLabelMap==null) {
                displayLabelMap = new Map<String, String>();
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationProgramDetails', 'Program__c'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationMatchingDisplay', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationInternalUse', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationConsentandWaivers', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('ProgramRegistrationTableFields',
                                                                             'Participant_Intern_Record__c'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationGeneral', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationEmergency', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationIncome', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('RegistrationParentGuardianInfo', 'Contact'));
                displayLabelMap.putAll(UtilityMethods.getFieldLabelMap('ProgramRegistrationUpdateFields',
                                                                             'Participant_Intern_Record__c'));
            
                for(Form_Label__mdt fl: [   Select MasterLabel, Object_API_Name__c, Custom_Label__c
                                            From Form_Label__mdt
                                            Where Form_Name__c = 'Registration'])
                displayLabelMap.put(fl.Object_API_Name__c+fl.MasterLabel, fl.Custom_Label__c);
            }
            return displayLabelMap;
        }
        set; }
    public List<Program__c> currProgRecords {
        get { 
                if(currProgRecords == null) {
                        currProgRecords = new List<Program__c>();
                        String query = 'Select Id ' + UtilityMethods.getFieldSetMemberAPINames('RegistrationProgramDetails', 'Program__c')
                                                + ' From Program__c '
                                                + ' Where Registration_Start__c < Today '
                                                + '     And Registration_End__c > Today '
                            + ' Order By Program_Descriptor__c ';
                        currProgRecords = Database.query(query);
                }
                return currProgRecords; 
                } set; }
    public Set<ID> currProgramIds {
        get { if(currProgramIds == null) {
                        currProgramIds = new Set<ID>();
                        for(Program__c pgm: currProgRecords)
                                currProgramIds.add(pgm.Id);
                }
        return currProgramIds;
        }
        set;
    }
    public String ptdid {get; set;}
    public String selectedContactId {get; set;}
    public String selectedProgramId {get; set;}
    public String selectedRegistrationId {get; set;}
    public String showCompletion {get; set;}
    
    public Contact cont {
        get { if(cont==null) cont = new Contact(); return cont; }
        set { cont = value; } }
    public List<Contact> listContactMatches {
        get ;
        set { listContactMatches = value; } }
    public PageReference resetSearch() {
        selectedContactId = null;
        listContactMatches = null;
        cont = null;

        return null; }


    public PageReference lookupContact() {
        showCompletion = 'false';
        String contactQuery = 'Select Id ' + UtilityMethods.getFieldSetMemberAPINames('RegistrationMatchingDisplay', 'Contact') 
                                                        + ' , (Select Id ' + UtilityMethods.getFieldSetMemberAPINames('ProgramRegistrationTableFields',
                                                                                                                                                 'Participant_Intern_Record__c')
                                                        + ' From Participant_Intern_Records__r Where Program__c In  :currProgramIds) '
                                                        + ' From Contact ';
        
        //Construct Where Clause based on selected search method
        if(ptdid!=null && ptdid != '')
                listContactMatches = Database.query(contactQuery + ' Where PTDID__c = :ptdid');
        if(cont.FirstName!=null && cont.LastName != null && cont.Birthdate != null)     {
                contactQuery = contactQuery + ' WHERE IsDeleted = FALSE ';
                for(Schema.FieldSetMember fsm: UtilityMethods.readFieldSet('RegistrationMatching', 'Contact')) 
                        contactQuery = contactQuery + ' AND ' + fsm.fieldPath + ' = ' 
                                + ( fsm.type==DisplayType.STRING? String.escapeSingleQuotes(((String)cont.get(fsm.fieldPath)))
                        .center(String.escapeSingleQuotes(((String)cont.get(fsm.fieldPath))).length()+2, '\'') : 
                                        ( fsm.type==DisplayType.DATE? DateTime.newInstance(
                                                                                                        ((Date)cont.get(fsm.fieldPath)).Year(), 
                                                                                                        ((Date)cont.get(fsm.fieldPath)).Month(), 
                                                                                                        ((Date)cont.get(fsm.fieldPath)).Day() ).format('yyyy-MM-dd') :
                                                cont.get(fsm.fieldPath))
                                        );
                contactQuery += ' Order By LastModifiedDate DESC Limit 1 ';
            System.Debug(contactQuery);
                listContactMatches = Database.query(contactQuery);
        }
        return null;

    }

    public PageReference contactSelect() {
        showCompletion = 'false';
        List<Contact> listReturnedContacts = new List<Contact>();
        String contactQuery = 'Select Id ' + UtilityMethods.getFieldSetMemberAPINames('RegistrationGeneral', 'Contact') 
                                                        + UtilityMethods.getFieldSetMemberAPINames('RegistrationEmergency', 'Contact') 
                                                        + UtilityMethods.getFieldSetMemberAPINames('RegistrationIncome', 'Contact') 
                                                        + UtilityMethods.getFieldSetMemberAPINames('RegistrationParentGuardianInfo', 'Contact') 
                                                        + ' , (Select Id ' + UtilityMethods.getFieldSetMemberAPINames('ProgramRegistrationTableFields',
                                                                                                                                                 'Participant_Intern_Record__c')
                                                                                                + UtilityMethods.getFieldSetMemberAPINames('ProgramRegistrationUpdateFields',
                                                                                                                                                 'Participant_Intern_Record__c')
                                                        + ' From Participant_Intern_Records__r Where Program__c In  :currProgramIds) '
                                                        + ' From Contact ';

                contactQuery = contactQuery + ' WHERE IsDeleted = FALSE And ID = :selectedContactId';
                
                listReturnedContacts = Database.query(contactQuery);

                if(listReturnedContacts.size()>0) {
                        cont = listReturnedContacts[0];
                        cont.Id = null;
                }
                else
                        cont = new Contact();
        return null;
    }
    public PageReference completeRegistration() {
        if(selectedContactId != null && selectedContactId != '' && selectedContactId != 'New')
                cont.Id = selectedContactId;

        try {
                upsert cont;
                
                if(selectedRegistrationId != '' && selectedRegistrationId != null) {
                        update cont.Participant_Intern_Records__r;
                }
                else {
                        Participant_Intern_Record__c pir = new Participant_Intern_Record__c (
                                Participant_Intern__c = cont.Id,
                                Program__c = selectedProgramId,
                                Status__c = 'Enrolled',
                    Grade__c = cont.Grade__c,
                                Date_Enrolled__c = Date.Today()
                        );
                        upsert pir;     
                }
                
            resetSearch();
            showCompletion = 'true';
        }
        catch (Exception e) { System.Debug(e.getMessage()); }

        return null;
    }
}