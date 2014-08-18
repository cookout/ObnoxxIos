//
//  OBNLoginViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNLoginViewController.h"
#import "OBNServerCommunicator.h"
#import "OBNSMSVerificationViewController.h"
#import "OBNState.h"
#import "OBNHomeViewController.h"

@interface OBNLoginViewController ()

@property (nonatomic, strong) IBOutlet UITextField *phoneNumber;
@property (nonatomic, strong) IBOutlet UIButton *verify;

- (IBAction)verify:(id)sender;

@end

@implementation OBNLoginViewController

- (IBAction)verify:(id)sender {
    // Send a verification call to the server
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    [server addObserver:self
             forKeyPath:@"verifyResponse"
                options:NSKeyValueObservingOptionNew
                context:nil];
    [server verifyPhoneNumber:self.phoneNumber.text];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)serverCommunicator
                        change:(NSString *)change
                       context:(void *)context {
    // Check if request succeeded.
    NSDictionary *response = ((OBNServerCommunicator *)serverCommunicator).verifyResponse;
    int success = ((NSString *)[response valueForKey:@"success"]).intValue;
        
    if (success) {
        // Proceed to next step of verification.
        OBNState *appState = [OBNState sharedInstance];
        appState.temporaryToken = [response valueForKey:@"temporaryUserCode"];
        dispatch_async(dispatch_get_main_queue(), ^{[appState saveToDisk];});
            
        OBNSMSVerificationViewController *smsCodeEntry = [[OBNSMSVerificationViewController alloc]init];
        [self presentViewController:smsCodeEntry animated:YES completion: ^{}];
    } else {
        // Something was wrong at this step
    }
}

- (BOOL)textField:(UITextField *)textField
        shouldChangeCharactersInRange:(NSRange)range
                    replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
    
    if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
        textField.text = decimalString;
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (hasLeadingOne) {
        [formattedString appendString:@"1 "];
        index += 1;
    }
    
    if (length - index > 3) {
        NSString *areaCode =
                [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ", areaCode];
        index += 3;
    }
    
    if (length - index > 3) {
        NSString *prefix =
                [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-", prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.phoneNumber.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    // Check if login is even required - if a sessionId is available, load the app
    OBNState *appState = [OBNState sharedInstance];
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    if (appState.sessionId) {
        OBNHomeViewController *hvc = [[OBNHomeViewController alloc] init];
        if (appState.deviceToken) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [server registerToken];
            });
        }
        [self presentViewController:hvc animated:NO completion: ^{}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
