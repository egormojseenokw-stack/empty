public with sharing class SessionCheckController{

    public Long startTime{get; set;}
    public String timeSpend{get; set;}

    public SessionCheckController() {
        startTime = DateTime.now().getTime();
        timeSpend = '0 minutes / 0 seconds';
    }
    
    public void returnTime(){
        Long currentTime = DateTime.now().getTime();
        Long milliseconds = currentTime - startTime;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        timeSpend = minutes+' minutes / '+seconds+' seconds';
    }
    
    @RemoteAction
    public static String returnTimeVF(Long startTime){
        Long currentTime = DateTime.now().getTime();
        Long milliseconds = currentTime - startTime;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        return minutes+' minutes / '+seconds+' seconds';
    }
}