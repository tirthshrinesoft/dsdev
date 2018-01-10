public class FinicityLenderPortalAPI {
   WebhookURL__c webhook = WebhookURL__c.getValues('Webhook_URL');
   	 public FinicityLenderPortalAPI()  {
        
  	  }  
    public FinicityLenderPortalAPI(String type)  {
        if(type != null && type == 'Finicity') {
            webhook = WebhookURL__c.getValues('Webhook_URL_Finicity');
        }else if(type != null && type == 'Experian')  {
             webhook = WebhookURL__c.getValues('Webhook_URL_Experian');
        }
  	  } 
   	    public String getAuthenticationToken() {
         System.debug('i  getauthication');
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        System.debug('finicityAggrAPI.Finicity_App_Key__c is : ' + finicityAggrAPI.Finicity_App_Key__c);
        String Finicity_Partner_Secret=finicityAggrAPI.Finicity_Partner_Secret__c;
        String Finicity_Partner_ID=finicityAggrAPI.Finicity_Partner_ID__c;
        Map<String,String> headerMap;
        
        if(headerMap==null){
            headerMap = new Map<String,String>();
        }
        headerMap.put('Finicity-App-Key',Finicity_App_Key);
        headerMap.put('Content-Type','application/json');
        headerMap.put('Accept','application/json');
        Credentials credentials = new Credentials();
        credentials.setPartnerSecret(Finicity_Partner_Secret);
        credentials.setPartnerId(Finicity_Partner_ID);
        String authenticationToken = getAuthenticationTokenAny(finicityAggrAPI.Authentication_Url__c,headerMap,credentials.toJsonRequest());
        system.debug('authenticationToken is : '+authenticationToken);
        return authenticationToken;
    } 
    
 	
    public String getAuthenticationTokenAny(String endPoint,Map<String,String> headerMap,String body){
         System.debug('in getauthicationany...');
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndPoint(endPoint);
        httpRequest.setTimeout(6000);
        
        if(headerMap!=null && headerMap.keySet().size()>0){
            for(String key:headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key));
            }
        }
        if(body!=null && body!=''){
            httpRequest.setBody(body);
        }
        HttpResponse httpResponse = http.send(httpRequest);
        if(httpResponse!=null){
            Access access = new Access();
            access = access.fromJson(httpResponse.getBody());
            return access.getToken();
        }else{
            return '';
        }
    }
   
   
    public String createCustomer(CreateCustomerWrapper wrapper){
        String token = getAuthenticationToken();
        
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        
        Map<String,String> headerMap1;
        
        if(headerMap1==null){
            headerMap1 = new Map<String,String>();
        }
        headerMap1.put('Finicity-App-Key',Finicity_App_Key);
        headerMap1.put('Finicity-App-Token', token);
        headerMap1.put('Content-Type','application/json');
        headerMap1.put('Accept','application/json');
        
        // String url='https://api.finicity.com/aggregation/v1/customers/testing';
        String customerId= createCustomerRequest(webhook.CreateCustomerURL__c, headerMap1, wrapper.toJsonRequest());
        
        return customerId;
    }
    
    public List<String> getConsumerReport(String consumerid){
        String token = getAuthenticationToken();
    	
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        
        Map<String,String> headerMap1;
        
        if(headerMap1==null){
            headerMap1 = new Map<String,String>();
        }
        headerMap1.put('Finicity-App-Key',Finicity_App_Key);
        headerMap1.put('Finicity-App-Token', token);
        headerMap1.put('Content-Type','application/json');
        headerMap1.put('Accept','application/json');
        
        String consumerReporturl='https://api.finicity.com/decisioning/v1/consumers/' + consumerid + '/reports';
        return getConsumerReportRequest(consumerReporturl, headerMap1);
    }
    
   public List<String> getConsumerReportRequest(String endPoint,Map<String,String> headerMap){
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setEndPoint(endPoint);
        httpRequest.setTimeout(60000);
        
        if(headerMap!=null && headerMap.keySet().size()>0){
            for(String key:headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key));
            }	
        }
		
       	HttpResponse httpResponse = http.send(httpRequest);
        if(httpResponse!=null){
           	ParseConsumerReportResponse parseConsumerReportResponse = new ParseConsumerReportResponse();
            List<String> listId = (List<String>)parseConsumerReportResponse.fromJson(httpResponse.getBody());
            System.debug('id:'+listId);
            return listId;
        }else{
            return new List<String>();
        } 
    }
    
    
    public String createCustomerRequest(String endPoint,Map<String,String> headerMap,String body){
        
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndPoint(endPoint);
        httpRequest.setTimeout(60000);
        
        if(headerMap!=null && headerMap.keySet().size()>0){
            for(String key:headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key));
            }
        }
        if(body!=null && body!=''){
            httpRequest.setBody(body);
            
        }
        system.debug('request:'+httpRequest.getBody());
        HttpResponse httpResponse = http.send(httpRequest);
        if(httpResponse!=null){
            
            GetCustomerId customer = new GetCustomerId();
            customer = customer.fromJson(httpResponse.getBody());
            if(customer.isError==true){
                throw new CustomException(customer.errorMessage);
            }
            return customer.id;
            
        }else{
            
            return null;
        } 
    }
    public String createConsumer(CreateConsumerWrapper cwrapper,String customerId){
        String token = getAuthenticationToken();
        
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        Map<String,String> headerMap1;
        
        if(headerMap1==null){
            headerMap1 = new Map<String,String>();
        }
        headerMap1.put('Finicity-App-Key',Finicity_App_Key);
        headerMap1.put('Finicity-App-Token', token); 
        headerMap1.put('Content-Type','application/json');
        headerMap1.put('Accept','application/json');
        headerMap1.put('customerId', customerId);
        
        //String url = webhook.CreateConsumerURL__c	+customerId+'/consumer';
        String url = webhook.CreateConsumerURL__c +customerId+'/consumer' ;
        String consumerId= createConsumerRequest(url, headerMap1, cwrapper.toJsonRequest());
        return consumerId;
    }
    
    public String createConsumerRequest(String endPoint,Map<String,String> headerMap,String body){
        
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndPoint(endPoint);
        httpRequest.setTimeout(60000);
        
        if(headerMap!=null && headerMap.keySet().size()>0){
            for(String key:headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key));
            }
        }
        if(body!=null && body!=''){
            httpRequest.setBody(body);
            
        }
        
        HttpResponse httpResponse = http.send(httpRequest);
        if(httpResponse!=null){
            
            GetConsumerId consumer = new GetConsumerId();
            consumer = consumer.fromJson(httpResponse.getBody());
            if(consumer.isError==true){
                throw new CustomException(consumer.errorMessage);
            }
            
            return consumer.id;
            
        }else{
            
            return null;
        } 
    }
    
    public String sendEmailToConsumer(ConsumerMailDataWrapper mwrapper){
        String token = getAuthenticationToken();
        system.debug('token::'+token);
        Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
        String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
        String Finicity_Partner_ID=finicityAggrAPI.Finicity_Partner_ID__c;
        Map<String,String> headerMap1;
        
        if(headerMap1==null){
            headerMap1 = new Map<String,String>();
        }
        headerMap1.put('Finicity-App-Key',Finicity_App_Key);
        headerMap1.put('Finicity-App-Token', token); 
        headerMap1.put('Content-Type','application/json');
        headerMap1.put('Accept','application/json');
        //headerMap1.put('webhookHeaders','{ "Authorization": "Bearer TOKEN_GOES_HERE"}');
		//"webhookHeaders": { "Authorization": "Bearer TOKEN_GOES_HERE"}
        
        //String url='https://api.finicity.com/connect/v1/send/email';
        //mwrapper.Email.from1 = null;
        String sendmail= sendEmailToConsumerRequest(webhook.sendEmailURL__c, headerMap1, mwrapper.toJsonRequest());
        return sendmail;
    }
    
    public String sendEmailToConsumerRequest(String endPoint,Map<String,String> headerMap,String body){
        
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndPoint(endPoint);
        httpRequest.setTimeout(60000);
        
        if(headerMap!=null && headerMap.keySet().size()>0){
            for(String key:headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key));
            }
        }
        if(body!=null && body!=''){
            httpRequest.setBody(body);
            
        }
        
        HttpResponse httpResponse = http.send(httpRequest);
        if(httpResponse!=null){
            MailResponseData response = new MailResponseData();
            response = response.fromJson(httpResponse.getBody());
            if(response.isError==true){
                throw new CustomException(response.errorMessage);
            }
            
            return response.getlink();
            
        }else{
            return null;
        } 
    }
    
    public String getVOIVOAReport(String url)  {
        return call(url,null,'<lender><purpose>0B</purpose></lender>','POST','application/xml','application/pdf');
    }
    
    public String call(String endPoint,Map<String,String> headerMap,String body,String method,String contentType,String acceptType){
        if(endPoint!=null && endPoint!=''){
            
            if(headerMap==null){
                headerMap = new Map<String,String>();
            }
            
            Finicity_Aggregation_API__c finicityAggrAPI = Finicity_Aggregation_API__c.getValues('FinicityCredential');
            String Finicity_App_Key=finicityAggrAPI.Finicity_App_Key__c;
            
            headerMap.put('Finicity-App-Key',Finicity_App_Key);
            headerMap.put('Content-Type',contentType);
            headerMap.put('Accept',acceptType);
            
            String authenticationToken = getAuthenticationToken();
            
            if(authenticationToken!=null && authenticationToken!=''){
                headerMap.put('Finicity-App-Token',authenticationToken);
                
                Http http = new Http();
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod(method);
                httpRequest.setEndPoint(endPoint);
                httpRequest.setTimeout(60000); 
                
                if(headerMap!=null && headerMap.keySet().size()>0){
                    for(String key:headerMap.keySet()){
                        httpRequest.setHeader(key,headerMap.get(key));
                    }
                }
                
                System.debug(headerMap);
                
                if(body!=null && body!=''){
                    
                    httpRequest.setBody(body);
                }
                
                HttpResponse httpResponse = http.send(httpRequest);
                
                if(httpResponse!=null){
                    System.debug(httpResponse);
                    List<String> resHeaderKeys=httpResponse.getHeaderKeys();
                    for(Integer i=0; i<resHeaderKeys.size(); i++){
                        if(resHeaderKeys[i] == 'Content-Disposition'){
                            System.debug('The value of the Content Disposition '+httpResponse.getHeader(resHeaderKeys[i]));
                        }
                    }
                    try{
                        return EncodingUtil.Base64Encode(httpResponse.getBodyAsBlob());
                    }catch(Exception e){
                        system.debug(e.getStackTraceString());
                    }
                    return null;
                }else{
                    
                    return null;
                }
            }else{
                
                return null;
            }
        }else{
            return null;
        }
        
    }
}