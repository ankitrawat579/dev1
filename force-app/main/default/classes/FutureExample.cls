public class FutureExample {
    @future(callout=true)
    public static void makeCallout() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/data');
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        System.debug(res.getBody());
    }
}