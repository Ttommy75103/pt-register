@isTest
private class RegistrationControllerTest {
	
	@isTest static void test_method_one() {
		Contact cont = new Contact();
		RegistrationController rc = new RegistrationController(new ApexPages.StandardController(cont));
		Map<String, String> mapDLM = rc.displayLabelMap;
		System.assertNotEquals(mapDLM.keySet().size(), 0);
	}
	
	@isTest static void test_method_two() {
		Date birthdate = Date.Today().addYears(-5);

		Contact cont = new Contact();
		RegistrationController rc = new RegistrationController(new ApexPages.StandardController(cont));
		
		//Create Test Data
		Contact cont2 = new Contact (
			FirstName = 'FName',
			LastName = 'LName',
			Email = 'abc@email.com',
            Birthdate = birthdate);
		upsert cont2;
		Program__c pgm = new Program__c (
			Registration_Start__c = Date.Today().addDays(-5),
			Registration_End__c = Date.Today().addDays(5)
			);
		upsert pgm;
		System.assertEquals(rc.currProgRecords.size(), 1);

		Contact cont3 = [Select Id, PTDID__c From Contact Where Id = :cont2.Id];
		
		rc.ptdid = cont3.PTDID__c;
		rc.lookupContact();
		List<Contact> listCont = rc.listContactMatches;
		System.assertEquals(listCont.size(), 1);

		rc.ptdid = null;
		rc.cont = new Contact();
		rc.cont.FirstName = 'FName';
		rc.cont.LastName = 'LName';
		rc.cont.Birthdate = birthdate;
		rc.lookupContact();
		List<Contact> listCont2 = rc.listContactMatches;
		System.assertEquals(listCont2.size(), 1);

		rc.selectedContactId = listCont2[0].Id;
		rc.contactSelect();

		rc.SelectedProgramId = pgm.Id;
		rc.completeRegistration();

		List<Participant_Intern_Record__c> pir = [Select Id From Participant_Intern_Record__c];
		System.assertEquals(pir.size(), 1);

	}
	
}