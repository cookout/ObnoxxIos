//
//  OBNRecordViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/31/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

//
//  OBRecordViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNRecordViewController.h"
#import "OBNServerCommunicator.h"

@interface OBNRecordViewController ()
@property (nonatomic, strong) IBOutlet UIButton *play;
@property (nonatomic, strong) IBOutlet UIButton *stop;
@property (nonatomic, strong) IBOutlet UIButton *record;
@property (nonatomic, strong) IBOutlet UIButton *send;
@property (nonatomic, strong) IBOutlet UITextField *receiver;


-(IBAction) play:(id) sender;
-(IBAction) record:(id) sender;
-(IBAction) stop:(id) sender;
-(IBAction) send:(id) sender;

@end

@implementation OBNRecordViewController


-(IBAction) play:(id) sender
{
    OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
    [audioManager play:self.recording.localUrl];
}

-(IBAction) send:(id) sender
{
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    [server addObserver:self forKeyPath:@"uploadResponse" options:NSKeyValueChangeNewKey context:@"sndS"];
    [server sendSound:self.recording.localUrl fileName:[self.recording.localUrl lastPathComponent]
       recipientPhone:self.receiver.text];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)response change:(NSString *)change context:(id) context
{
    
    if([context isEqualToString:@"sndS"])
    {
        // Do something! The server responded to our send sound attempt
    }
}

-(IBAction) record:(id) sender
{
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                 objectAtIndex:0];
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString *fileName = [[NSString alloc] initWithFormat:@"recording-%@.m4a",caldate];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:fileName];
    self.recording = [[OBNAudioManager sharedInstance] record:filePath];
}

-(IBAction) stop:(id) sender
{
    [[OBNAudioManager sharedInstance]stop];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Record";
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