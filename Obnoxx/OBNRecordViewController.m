//
//  OBRecordViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNRecordViewController.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface OBNRecordViewController ()
@property (nonatomic, strong) IBOutlet UIButton *play;
@property (nonatomic, strong) IBOutlet UIButton *record;
@property (nonatomic, strong) AVAudioRecorder *aRec;
@property (nonatomic, strong) AVAudioPlayer *aPlay;

-(IBAction) play:(id) sender;
-(IBAction) record:(id) sender;

@end

@implementation OBNRecordViewController


-(IBAction) play:(id) sender
{
    self.aPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:self.aRec.url error:NULL];
    [self.aPlay play];
}

-(IBAction) record:(id) sender
{
    [self.aRec recordForDuration:3];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Record";
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        NSMutableDictionary *recordSetting;
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        [audioSession setActive:YES error:&err];
        err = nil;
        if(err){
            NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        
        recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        // Create a new dated file
        NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *caldate = [now description];
        NSString *recorderFilePath = [[NSString alloc] initWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER,caldate];
        NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
        err = nil;
        self.aRec = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];

        
        
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
