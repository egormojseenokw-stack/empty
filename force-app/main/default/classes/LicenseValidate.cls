@RestResource(urlMapping='/checkValidation')
global without sharing class LicenseValidate {
    @HttpGet
    global static String doGet() {
        String name = RestContext.request.params.get('name');
        List<Account> accList = [SELECT ID FROM Account WHERE Name=:name LIMIT 1];
        if(accList.size() > 0){
            return 'Account with this name exist in the org.';
        }
        else{
            return 'Account with this name don\'t exist in the org.';
        }
    }
}