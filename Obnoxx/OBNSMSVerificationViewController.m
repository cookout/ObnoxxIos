//
//  OBNSMSVerificationViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNSMSVerificationViewController.h"
#import "OBNServerCommunicator.h"
#import "OBNState.h"
#import  "OBNHomeViewController.h"

@interface OBNSMSVerificationViewController ()
@property (nonatomic, strong) IBOutlet UIButton *verifyButton;
@property (nonatomic, strong) IBOutlet UITextField *verificationCode;

-(IBAction) verify: (id) sender;

@end

@implementation OBNSMSVerificationViewController

-(IBAction) verify: (id) sender
{
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    
    [server addObserver:self forKeyPath:@"verifyResponse" options:NSKeyValueChangeNewKey context:@"sms"];
    [server verifyCode:self.verificationCode.text];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)response change:(NSString *)change context:(id) context
{
    
    if([context isEqualToString:@"sms"])
    {
        // Something happened to the verify response object
        //NSLog(@"%@, %@, %@, %@", keyPath, ((OBNServerCommunicator *)response).verifyResponse, change, context);
        
        // Check if request succeeded
        OBNServerCommunicator *server = response;
        int success = ((NSString *)[server.verifyResponse valueForKey:@"success"]).intValue;
        
        if(success)
        {
            // Proceed to next step of verification
            OBNHomeViewController *hvc = [[OBNHomeViewController alloc] init];
            OBNState *appState = [OBNState sharedInstance];
            appState.sessionId = [server.verifyResponse valueForKeyPath:@"sessionId"];
            dispatch_async(dispatch_get_main_queue(), ^{[appState saveToDisk];});
            [self presentViewController:hvc animated:YES completion:^{}];
        }
        else
        {
            // Something was wrong at this step
        }
        
    }
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
