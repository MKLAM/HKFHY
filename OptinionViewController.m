//
//  OptinionViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月29日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "OptinionViewController.h"
@implementation OptinionViewController

@synthesize formScrollView, nameField, emailField, phoneField, remarkField, submitBtn, resetBtn, textArea, tab1,tab2,tab3, languageChangeBtn, homeBtn, fontSizeChangeBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    msg = [[MessageProcessor alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [tap release];
    [nameField setDelegate:self];
    [emailField setDelegate:self];
    [phoneField setDelegate:self];
    [remarkField setDelegate:self];
    [textArea setDelegate:self];
    
    formType = @"comment";
    [self setLayout];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];
    [phoneField resignFirstResponder];
    [remarkField resignFirstResponder];
    [textArea resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
        
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    // We do not want UITextField to insert line-breaks.
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView{
    if([textView.text length]>0){
        remarkField.placeholder = @"";
    }else{
        remarkField.placeholder = [msg GetString:@"remark_placeholder"];
    }
}

-(void) loadData{
    NSString *language = [msg ReadSetting:@"language"];
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", language]] forState:UIControlStateNormal];
    nameField.placeholder = [msg GetString:@"name_placeholder"];
    emailField.placeholder = [msg GetString:@"email_placeholder"];
    phoneField.placeholder = [msg GetString:@"phone_placeholder"];
    if([textArea.text length]==0){
        remarkField.placeholder = [msg GetString:@"remark_placeholder"];
    }
    [submitBtn setTitle:[msg GetString:@"submit_btn"] forState:UIControlStateNormal];
    [resetBtn setTitle:[msg GetString:@"cancel"] forState:UIControlStateNormal];
    [tab1 setTitle:[msg GetString:@"opinion"] forState:UIControlStateNormal];
    [tab2 setTitle:[msg GetString:@"complain"] forState:UIControlStateNormal];
    [tab3 setTitle:[msg GetString:@"inpuiry"] forState:UIControlStateNormal];
    if([formType isEqualToString:@"comment"]){
        [tab1 setSelected:YES];
    }
    if([formType isEqualToString:@"compain"]){
        [tab2 setSelected:YES];
    }
    if([formType isEqualToString:@"inquiry"]){
        [tab3 setSelected:YES];
    }
    
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    
}
-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
            
        }
    }
    formScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

-(IBAction)ChangeLanguage:(id)sender{
    [msg ChangeLanguage];
    [self loadData];
}

-(IBAction)ChangeFont:(id)sender{
    [msg ChangeFont];
    [self loadData];
}

-(IBAction)BackHome:(id)sender{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)ChangeTab:(id)sender{
    UIButton *clickedBtn = sender;
    [tab1 setSelected:NO];
    [tab2 setSelected:NO];
    [tab3 setSelected:NO];
    if(clickedBtn.tag == 0){
        [tab1 setSelected:YES];
        formType = @"comment";
    }else if(clickedBtn.tag == 1){
        [tab2 setSelected:YES];
        formType = @"compain";
    }else{
        [tab3 setSelected:YES];
        formType = @"inquiry";
    }
}

-(IBAction)ResetForm{
    nameField.text = @"";
    emailField.text = @"";
    phoneField.text = @"";
    textArea.text = @"";
    remarkField.placeholder = [msg GetString:@"remark_placeholder"];
}

-(IBAction)SubmitForm{
    Reachability *internetReach;
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"no_network"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles: nil];
        [alert show];
        [alert release];
    }else{
        BOOL valid = true;
        NSString *msg1 = @"";
        NSString *msg2 = @"";
        if([nameField.text length]<=0){
            valid = false;
            msg1 = [msg GetString:@"name_invalid"];
        }
        if([textArea.text length]<=0){
            valid = false;
            msg2 = [msg GetString:@"content_invalid"];
        }
        
        if(!valid){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"invalid_form"] message:[NSString stringWithFormat:@"%@\n%@", msg1, msg2] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles: nil];
            [alert show];
            [alert release];
        }else{
            BOOL result = [self PostToServer];
            if(result){
                [self ResetForm];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"submit_success"] message:[msg GetString:@"submit_msg"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles: nil];
                [alert show];
                [alert release];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"submit_fail"] message:[msg GetString:@"system_error"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
    }
    [internetReach release];
}

-(BOOL)PostToServer{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [msg ReadSetting:@"domain"], [msg ReadSetting:@"comment_feed"]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:formType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    if([nameField.text length]>0){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:nameField.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if([emailField.text length]>0){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:emailField.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if([phoneField.text length]>0){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"tel\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:phoneField.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if([textArea.text length]>0){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"content\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:textArea.text] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    //return and test
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
    if(error){
        [returnString release];
        return NO;
    }else{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *output = [parser objectWithString:returnString];
        BOOL result = [[output objectForKey:@"success"] intValue] == 1;
        [parser release];
        [returnString release];
        return result;
    }
    return NO;
}

-(void) dealloc{
    [msg release];
    [super dealloc];
}


@end
