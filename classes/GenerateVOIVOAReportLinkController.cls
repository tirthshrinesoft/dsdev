public class GenerateVOIVOAReportLinkController {
    
    public Case caseObj {get;set;}
    public Account actObj {get;set;}
    public String firstname {get;set;}
    public String lastname {get;set;}
    public String username {get;set;}
    public string address {get;set;}
    public string city {get;set;}
    public String state {get;set;}
    public String zip {get;set;}
    public String phone {get;set;}
    public String ssn {get;set;}
    public String birthdate {get;set;}
    public String email {get;set;}
    public String year{get;set;}
    public String month{get;set;}
    public String dayOfMonth{get;set;}
    public Boolean showPage{get;set;}
    public String link {get;set;}
    public String reportType {get;set;}
    public Boolean isNewAccount {get;set;}
    public String customerId {get;set;}
    public String consumerid {get;set;}
    public String type {get;set;}
    public GenerateVOIVOAReportLinkController(){
        caseObj=[select id,AccountId,Dispute_Reference_Number__c,ReportType__c,ReportLink__c  from case where id=:ApexPages.currentPage().getParameters().get('id')].get(0); 
        reportType = caseObj.ReportType__c;
        
        type = ApexPages.currentPage().getParameters().get('type');
                
        if(caseObj.AccountId !=null){
        	isNewAccount = false;
            actObj=[select id,FirstName,LastName,CustomerId__c,ConsumerID__c,PersonEmail,PersonMailingAddress,PersonMailingCity,PersonMailingCountry,PersonMailingPostalCode,PersonMailingState,PersonMailingStreet,PersonBirthdate,Phone from Account where id=:caseobj.AccountId].get(0);
        }else {
        	isNewAccount = true;
        	actObj = new Account();
        }
        
        if(actObj != null){
            firstname=actObj.FirstName;
            lastname=actObj.LastName;
            email = actObj.PersonEmail;
            address = actObj.PersonMailingStreet;
            city=actObj.PersonMailingCity;
            state=actObj.PersonMailingState;
            zip = actObj.PersonMailingPostalCode;
            phone=actObj.Phone;
            if(actObj.PersonBirthdate != null)  {
            	birthDate = actObj.PersonBirthdate.Month() + '/' + actObj.PersonBirthdate.Day() + '/' + actObj.PersonBirthdate.Year(); 
            }
            /*
            if(actObj.PersonBirthdate!=null){
                year=string.valueOf(actObj.PersonBirthdate.year());
                month=string.valueOf(actObj.PersonBirthdate.month());
                dayOfMonth=string.valueOf(actObj.PersonBirthdate.day());
            } 
            */
        }
        
    }
    
    public List<SelectOption> getReportTypeList()  {
    	List<SelectOption> reportTypeList = new List<SelectOption>();
        reportTypeList.add(new SelectOption('','Select Report Type'));
        reportTypeList.add(new SelectOption('voi','voi'));
        reportTypeList.add(new SelectOption('voa','voa'));
        return reportTypeList;
    }
    
    public void getConsumerId1(){
        
		FinicityLenderPortalAPI api= new FinicityLenderPortalAPI(type);
        
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        String Finicity_Partner_ID=finicityAggrAPI.Finicity_Partner_ID__c;
        WebhookURL__c url = new WebhookURL__c();
        
        system.debug('MYT:-' +type);
        
        if(type != null && type == 'Finicity'){
            url = WebhookURL__c.getValues('Webhook_URL_Finicity');
        }else if(type != null && type == 'Experian'){
            url = WebhookURL__c.getValues('Webhook_URL_Experian');
        }
        
        system.debug('URL:-'+url);
        
        
        customerId=actObj.CustomerId__c;
        try{
        	if(customerId==null || customerId==''){
        		username = 'SfGeneratedId@'+System.now()+'';
        		username = username.replaceAll(' ','');
        		username = username.replaceAll(':','');
        		username = username.replaceAll('-','');
        		username += userInfo.getUserId();
        		System.debug('username is : ' + username);
				CreateCustomerWrapper customerWrapper=new CreateCustomerWrapper();
				customerWrapper.username=username;
        		customerWrapper.firstName=firstName;
        		customerWrapper.lastName=lastName;
				customerId =api.createCustomer(customerWrapper);   
				actObj.CustomerId__c=customerId;
			}
			
			consumerid = actObj.ConsumerID__c;

			if(consumerid==null || consumerid==''){
				CreateConsumerWrapper cwrapper=new CreateConsumerWrapper();
				cwrapper.firstName=firstName;
            	cwrapper.lastName=lastName;
            	cwrapper.email=email;
            	cwrapper.address=address;
            	cwrapper.city=city;
            	cwrapper.state=state;
            	cwrapper.zip=zip;
            	cwrapper.phone=phone;
            	cwrapper.ssn=ssn;
            	if(birthDate != null)  {
            		Date d= Date.parse(birthDate);
            		cwrapper.Birthdayw.year=string.valueOf(d.year());
					cwrapper.Birthdayw.month=string.valueOf(d.month());
                	cwrapper.Birthdayw.dayOfMonth=string.valueOf(d.day());
            	}
				consumerid=api.createConsumer(cwrapper,customerId);
				actObj.ConsumerID__c=consumerid;
			}
            caseobj.ReportType__c = reportType;
                    
			ConsumerMailDataWrapper mwrapper= new ConsumerMailDataWrapper();
			mwrapper.partnerId=Finicity_Partner_ID;
            mwrapper.consumerId=consumerid;
            mwrapper.customerId=customerId;
            mwrapper.redirectUri=url.redirectUri__c;
            mwrapper.type = reportType;
            mwrapper.webhook=url.URL__c+ caseObj.id;
            mwrapper.webhookContentType = url.webhookContentType__c ;
            //mwrapper.Email.from1=url.From__c;
            mwrapper.Email.to= email; 
            mwrapper.Email.supportPhone= url.supportPhone__c;
            mwrapper.Email.subject= reportType + ' Report Account Verification Link'; //Your new ' + reportType + ' Report';
            mwrapper.Email.firstName=firstname;
            mwrapper.Email.brandColor=url.brandColor__c;
            mwrapper.Email.brandLogo=url.brandLogo__c;
            mwrapper.Email.institutionName= url.institutionName__c;
            mwrapper.Email.institutionAddress= url.institutionAddress__c;
            link=api.sendEmailToConsumer(mwrapper);
                      
            if(link!=null){
            	caseobj.ReportLink__c= (caseobj.ReportLink__c!=null?caseobj.ReportLink__c:'') +'\n'+link;
			}
                        
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Report is created and email sent to emailId : '+mwrapper.Email.to+', click on cancel button to go back to case.'));
                    
                
		}catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error.'+ e.getMessage()));
            system.debug('TRACE:-'+e.getStackTraceString()+e.getMessage()+e.getLineNumber());
		}finally {
			if(isNewAccount && actObj.Id == null)  {
				actObj.FirstName=firstName;
				actObj.LastName=lastName;
				actObj.personEmail = email;
                actObj.PersonMailingStreet = address;
            	actObj.PersonMailingCity = city;
            	actObj.PersonMailingState = state;
            	actObj.PersonMailingPostalCode = zip;
            	actObj.Phone = phone;
            	actObj.CustomerId__c = customerId;
            	actObj.ConsumerID__c = consumerid;
            	if(birthDate != null)  {
            		actObj.personBirthDate = Date.parse(birthDate);
            	}
                Id personAccountId = [SELECT Id,Name FROM RecordType where sObjectType = 'Account' and name='Consumer Account'].Id;
                actObj.recordTypeId = personAccountId;
                try  {
                	insert actObj;
                }catch(Exception ex)  {
	                actObj.OwnerId  = '00536000003qvtu';
                	insert actObj;
                }
                caseObj.accountId = actObj.Id;
                
			}else  {
				actObj.CustomerId__c = customerId;
            	actObj.ConsumerID__c = consumerid;
                if( actObj.FirstName == null ||  actObj.FirstName == '')  {
                    actObj.FirstName=firstName;
                }
                if( actObj.LastName == null ||  actObj.LastName == '')  {
                	actObj.LastName=lastName;
                }
                if( actObj.personEmail == null ||  actObj.personEmail == '')  {
                	actObj.personEmail = email;
                }
                if( actObj.PersonMailingStreet == null ||  actObj.PersonMailingStreet == '')  {
                	actObj.PersonMailingStreet = address;
                }
                if( actObj.PersonMailingCity == null ||  actObj.PersonMailingCity == '')  {
                	actObj.PersonMailingCity = city;
                }
                if( actObj.PersonMailingState == null ||  actObj.PersonMailingState == '')  {
                 	actObj.PersonMailingState = state;   
                }
                if( actObj.PersonMailingPostalCode == null ||  actObj.PersonMailingPostalCode == '')  {
                    actObj.PersonMailingPostalCode = zip;
                }
                if( actObj.Phone == null ||  actObj.Phone == '')  {
                    actObj.Phone = phone;
                }
				update actObj;
			}
			update caseObj;
		}
	} 
}