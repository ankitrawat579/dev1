@RestResource(urlMapping='/CustomEndpoint/*')
global with sharing class CustomRestAPI {
    @HttpGet
    global static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry FROM Account];
    }
    
    @HttpPost
    global static String createAccount(String accountName) {
        Account acc = new Account(Name = accountName);
        insert acc;
        return acc.Id;
    }
}