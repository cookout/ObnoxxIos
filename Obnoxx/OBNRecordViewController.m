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

@interface OBNRecordViewController ()
@property (nonatomic, strong) IBOutlet UIButton *play;
@property (nonatomic, strong) IBOutlet UIButton *stop;
@property (nonatomic, strong) IBOutlet UIButton *record;

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AERecorder *audioRecorder;

-(IBAction) play:(id) sender;
-(IBAction) record:(id) sender;
-(IBAction) stop:(id) sender;

@end

@implementation OBNRecordViewController


-(IBAction) play:(id) sender
{
    if(self.recording.localUrl)
    {
        NSURL *file = [[NSBundle mainBundle] URLForResource:self.recording.localUrl withExtension:@"m4a"];
        AEAudioFilePlayer *player = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                  audioController:_audioController
                                            error:NULL];
        NSLog(@"File URL %@",self.recording.localUrl);
        [_audioController addChannels:[NSArray arrayWithObjects:player,nil]];
    }
}

-(IBAction) record:(id) sender
{
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                 objectAtIndex:0];
    
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString *fileName = [[NSString alloc] initWithFormat:@"recording-%@",caldate];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:fileName];
    self.recording.localUrl = filePath;
    
    NSError *error = NULL;
    
    // Receive both audio input and audio output. Note that if you're using
    // AEPlaythroughChannel, mentioned above, you may not need to receive the input again.
    
    if ( ![self.audioRecorder beginRecordingToFileAtPath:filePath
                                                fileType:kAudioFileM4AType
                                                   error:&error] ) {
        // Report error
        NSLog(@"Error initializing audio recorder");
        return;
    }
    
    [_audioController addInputReceiver:self.audioRecorder];
    [_audioController addOutputReceiver:self.audioRecorder];
}

-(IBAction) stop:(id) sender
{
    [self.audioController removeInputReceiver:self.audioRecorder];
    [self.audioController removeOutputReceiver:self.audioRecorder];
    [self.audioRecorder finishRecording];
    self.audioRecorder = nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Record";
        
        // The Amazing Audio Engine-based audio controller
        self.audioController = [[AEAudioController alloc]
                                initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                                inputEnabled:YES];
        
        NSError *error = NULL;
        BOOL result = [_audioController start:&error]; //blocking call - interesting
        if ( !result ) {
            // The audio controller did not initialize correctly
        }
        
        self.audioRecorder = [[AERecorder alloc] initWithAudioController:_audioController];
        self.recording = [[OBNSound alloc]init];
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