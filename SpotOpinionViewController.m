//
//  SpotOpinionViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月27日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "SpotOpinionViewController.h"

@implementation SpotOpinionViewController

@synthesize pageTitle, formScrollView, nameField, emailField, phoneField, uploadBtn, imagePreview, remarkField, submitBtn, resetBtn, textArea, languageChangeBtn, homeBtn, fontSizeChangeBtn;

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
    
    CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    int thisId = self.spotID;
    NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND record_id = %d", language, thisId];
    
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    
    if([spotDataHelper.fetchedResultsController.fetchedObjects count] > 0 ){
        spotDetail = [spotDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
        
        for (UIView *view in pageTitle.subviews) {
            [view removeFromSuperview];
        }
        
        UILabel *titleFirst = [[UILabel alloc] init];
        titleFirst.text = [msg GetString:@"spot_opinion_title"];
        titleFirst.textColor = [UIColor colorWithRed:(58/255.0) green:(58/255.0) blue:(58/255.0) alpha:1];
        titleFirst.font = [UIFont boldSystemFontOfSize:14];
        CGFloat firstWidth =  [titleFirst.text sizeWithFont:[UIFont systemFontOfSize:14 ]].width;
        CGFloat firstHeight =  [titleFirst.text sizeWithFont:[UIFont systemFontOfSize:14 ]].height;
        
        UILabel *titleSecond = [[UILabel alloc] init];
        titleSecond.text = spotDetail.title;
        titleSecond.textColor = [UIColor colorWithRed:(244/255.0) green:(91/255.0) blue:(0/255.0) alpha:1];
        titleSecond.font = [UIFont boldSystemFontOfSize:14];
        CGFloat secondWidth =  [titleSecond.text sizeWithFont:[UIFont systemFontOfSize:14 ]].width;
        CGFloat secondHeight =  [titleSecond.text sizeWithFont:[UIFont systemFontOfSize:14 ]].height;
        if(secondWidth>140){
            secondWidth = 140;
        }
        
        
        UILabel *titleThird = [[UILabel alloc] init];
        titleThird.text = [msg GetString:@"spot_opinion_title2"];
        titleThird.textColor = [UIColor colorWithRed:(58/255.0) green:(58/255.0) blue:(58/255.0) alpha:1];
        titleThird.font = [UIFont boldSystemFontOfSize:14];
        CGFloat thirdWidth =  [titleThird.text sizeWithFont:[UIFont systemFontOfSize:14 ]].width;
        CGFloat thirdHeight =  [titleThird.text sizeWithFont:[UIFont systemFontOfSize:14 ]].height;
        
        CGFloat startX = pageTitle.frame.size.width;
        
        startX = (startX - firstWidth - secondWidth - thirdWidth)/2;
        titleFirst.frame = CGRectMake(startX, 8, firstWidth, firstHeight);
        [pageTitle addSubview:titleFirst];
        
        titleSecond.frame = CGRectMake(startX + firstWidth, 8, secondWidth, secondHeight);
        [pageTitle addSubview:titleSecond];
        
        titleThird.frame = CGRectMake(startX + firstWidth + secondWidth, 8, thirdWidth, thirdHeight);
        [pageTitle addSubview:titleThird];
        
        [titleFirst release];
        [titleSecond release];
        [titleThird release];
        
        nameField.placeholder = [msg GetString:@"name_placeholder"];
        emailField.placeholder = [msg GetString:@"email_placeholder"];
        phoneField.placeholder = [msg GetString:@"phone_placeholder"];
        if([textArea.text length]==0){
            remarkField.placeholder = [msg GetString:@"remark_placeholder"];
        }
        [uploadBtn setTitle:[msg GetString:@"upload_btn"] forState:UIControlStateNormal];
        [submitBtn setTitle:[msg GetString:@"submit_btn"] forState:UIControlStateNormal];
        [resetBtn setTitle:[msg GetString:@"cancel"] forState:UIControlStateNormal];

    }
    [spotDataHelper release];
    
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

-(IBAction)SelectImage
{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[msg GetString:@"select_image"] delegate:self cancelButtonTitle:[msg GetString:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[msg GetString:@"from_library"], [msg GetString:@"from_cam"], nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self FromLibrary];
    } else if (buttonIndex == 1) {
        [self FromCam];
    }
}

-(void)FromCam{
    @try
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [picker setDelegate:self];
        
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    @catch (NSException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"no_camara"] message:[msg GetString:@"cammara"] delegate:self cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)FromLibrary{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker setDelegate:self];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}


-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *pickedImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
    
    // do something with pickedImage
    [imagePreview setImage:pickedImage];
    [imagePreview setHidden:NO];
    
    [pickedImage release];
}

-(IBAction)ResetForm{
    nameField.text = @"";
    emailField.text = @"";
    phoneField.text = @"";
    textArea.text = @"";
    remarkField.placeholder = [msg GetString:@"remark_placeholder"];
    imagePreview.image = nil;
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [msg ReadSetting:@"domain"], [msg ReadSetting:@"spot_comment_feed"]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // file
    if(imagePreview.image!=nil){
        NSData *imageData = UIImageJPEGRepresentation(imagePreview.image, 100);
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: attachment; name=\"attachment[]\"; filename=\"attachment.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"%d", self.spotID]] dataUsingEncoding:NSUTF8StringEncoding]];
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
    [spotDetail release];
    [super dealloc];
}

@end
