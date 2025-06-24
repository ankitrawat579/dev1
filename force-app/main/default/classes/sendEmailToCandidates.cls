public with sharing class sendEmailToCandidates {

    public class EmailRequest {
        @InvocableVariable(required=true)
        public String toAddress;

        @InvocableVariable(required=true)
        public String subject;

    }

    @InvocableMethod(label='Send Email To Candidates' description='Send an email using Flow')
    public static void sendEmailToCandidates(List<EmailRequest> requests) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (EmailRequest req : requests) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { req.toAddress });
            email.setSubject(req.subject);

            String bodyText = 'Dear Candidate,\n\nThank you for your interest. We will get back to you soon.\n\nRegards,\nYour Company Name';
            email.setPlainTextBody(bodyText);

            emails.add(email);
        }

        try {
            Messaging.sendEmail(emails);
        } catch (Exception e) {
            System.debug('Failed to send email: ' + e.getMessage());
        }
    }
}