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
#import "OBNState.h"
#import "OBNSound.h"
#import "OBNDelivery.h"

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

-(IBAction) applyFilter1:(id) sender;
-(IBAction) applyFilter2:(id) sender;
-(IBAction) applyFilter3:(id) sender;

@end

@implementation OBNRecordViewController


-(IBAction) play:(id) sender
{
    OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
    [audioManager play:self.recording.localUrl isRecording:NO filter:nil];
}

-(IBAction) send:(id) sender
{
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];

    [server addObserver:self forKeyPath:@"uploadResponse" options:NSKeyValueChangeNewKey context:@"sndS"];
//    [server sendSound:self.recording.localUrl fileName:[self.recording.localUrl lastPathComponent]
//       recipientPhone:self.receiver.text];
    
    NSRange fileName = [self.recording.localUrl rangeOfString:[self.recording.localUrl lastPathComponent]];
    NSRange path = NSMakeRange(0, self.recording.localUrl.length-fileName.length);
    NSMutableString *newName = [[NSMutableString alloc] initWithString:[self.recording.localUrl substringWithRange:path]];
    [newName appendString:@"proc.m4a"];
    
    [server sendSound:newName fileName:@"proc.m4a" recipientPhone:self.receiver.text];
}


-(IBAction) applyFilter1:(id)sender
{
    [[OBNAudioManager sharedInstance] addFilter:kCuji path:self.recording.localUrl];
}

-(IBAction) applyFilter2:(id)sender
{
    [[OBNAudioManager sharedInstance] addFilter:kKaraka path:self.recording.localUrl];
}

-(IBAction) applyFilter3:(id)sender
{
    [[OBNAudioManager sharedInstance] addFilter:kPopHero path:self.recording.localUrl];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)response change:(NSString *)change context:(id) context
{
    
    if([context isEqualToString:@"sndS"])
    {
        NSDictionary *uploadResponse = ((OBNServerCommunicator *)response).uploadResponse;
        
        // Rename the local sound file
        /*NSRange fileName = [self.recording.localUrl rangeOfString:[self.recording.localUrl lastPathComponent]];
        NSRange path = NSMakeRange(0, self.recording.localUrl.length-fileName.length);
        NSMutableString *newName = [[NSMutableString alloc] initWithString:[self.recording.localUrl substringWithRange:path]];
        [newName appendFormat:@"%@.m4a",[[uploadResponse valueForKey:@"sound"] valueForKey:@"id"]];
        [[NSFileManager defaultManager] moveItemAtPath:self.recording.localUrl toPath:newName error:nil];
        
        // Add the saved sound details to the local state data structure
        OBNSound *savedSound = [[OBNSound alloc] initWithDictionary:[uploadResponse valueForKey:@"sound"]];
        savedSound.localUrl = newName;
        OBNState *appState = [OBNState sharedInstance];
        [appState.sounds addObject:savedSound];
        
        // Add the sound delivery to the delivery data structure
        OBNDelivery *delivery = [[OBNDelivery alloc] initWithDictionary:[uploadResponse valueForKey:@"soundDeliveries"][0]];
        [appState.deliveries addObject:delivery];
        
        // Save app state
        [appState saveToDisk];
        
        // Display a message that confirming that the sound was posted
        UIAlertView * newAlert = [[UIAlertView alloc]init];
        newAlert.message = @"Sound sent!";
        [newAlert addButtonWithTitle:@"Ok"];
        [newAlert show];*/
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