//
//  ViewController.m
//  PainLogger
//
//  Created by Nhan Do on 11/15/15.
//  Copyright © 2015 Nhan Do. All rights reserved.
//

#import "ViewController.h"
#import <MailCore/mailcore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _pain_values = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIPickerView DataSource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pain_values.count;
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _pain_values[row];
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView*) pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSString *resultString = [[NSString alloc] initWithString:_pain_values[row]];
    
    _resultLabel.text = resultString;
    
}


NSString* CreateEncryptedLog(NSString* log_string, NSString* picked_value){
    NSDictionary *map = @{
             @"1" : @"437",
             @"2" : @"657",
             @"3" : @"175",
             @"4" : @"173",
             @"5" : @"985",
             @"6" : @"254",
             @"7" : @"234",
             @"8" : @"576",
             @"9" : @"478",
             @"10" : @"495",
             };
    
    NSString* encrypted_string =
        XORCipher( [log_string stringByAppendingString: map[picked_value]]);
    
    return [encrypted_string stringByAppendingString:@"\n"];
}

NSString* XORCipher(NSString* input){
    NSString* pwd = @"cp_AQLC}<=FWBp_bgiJN$w:jH_r<??";
    NSMutableString* output = [[NSMutableString alloc] init];
    
    for (int i =0; i<input.length; i++){
        char c = [input characterAtIndex:i];
        int j = i % pwd.length;
        c ^= [pwd characterAtIndex:j];
        [output appendString:[NSString stringWithFormat:@"%c", c]];
    }
    return output;
}

- (IBAction)SubmitValue:(id)sender {
    NSInteger row = [_picker selectedRowInComponent:0];
    NSString *resultString = [[NSString alloc] initWithString:_pain_values[row]];
   
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to submit this value?" message:resultString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"User submits value!");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"PainLog.txt"];
        
        // Get the date, time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        
        NSString *savedString = [NSString stringWithFormat:@"%@ | ", [dateFormatter stringFromDate:[NSDate date]]];
        NSString* encrypted_string = CreateEncryptedLog(savedString, resultString);
        
        // if file does not exist, create it and write to file (else append to file)
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:documentTXTPath]){
            NSError *error;
            BOOL write_ok = [encrypted_string writeToFile:documentTXTPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (!write_ok){
                NSLog(@"Error writing file at %@\n%@", documentTXTPath, [error localizedFailureReason]);
            }
        }
        else{
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[encrypted_string dataUsingEncoding:NSUTF8StringEncoding]];
        }
        //NSLog(@"File paht at %@\n", documentTXTPath);
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction: ok];
    [alert addAction: cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    NSLog(@"%@", resultString);
}

- (IBAction)SendEmail:(id)sender {
    NSLog(@"User sends email!");
    NSString * USERNAME = @"epione01";
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"mail-relay.iu.edu";
    smtpSession.port = 465;
    smtpSession.username = USERNAME;
    smtpSession.password = @"Det var saa lidt!";
    smtpSession.authType = (MCOAuthTypeSASLPlain | MCOAuthTypeSASLLogin);
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:USERNAME]];
    NSMutableArray *to = [[NSMutableArray alloc] init];
    
    /*for(NSString *toAddress in RECIPIENTS) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
        [to addObject:newAddress];
    }*/
    
    NSString *toAddress = @"epione@iupui.edu";
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
    [to addObject:newAddress];
    
    [[builder header] setTo:to];
    
    [[builder header] setSubject:@"Test email painlogger"];
    [builder setHTMLBody:@"Hello World"];
    
    // Attachment
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"PainLog.txt"];
    MCOAttachment *attachment = [MCOAttachment attachmentWithContentsOfFile:documentTXTPath];
    [builder addAttachment:attachment];
    
    NSData *rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error){
        if(error) {
            NSLog(@"%@ Error sending email:%@", USERNAME, error);
            NSString* error_message = [NSString stringWithFormat:@"Error sending email: %@", error];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Send email" message:error_message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"%@ Successfully sent email!", USERNAME);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Send email" message:@"Send email successfully!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}



@end
