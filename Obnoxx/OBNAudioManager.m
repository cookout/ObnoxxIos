//
//  OBNAudioManager.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/5/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNAudioManager.h"

@implementation OBNAudioManager

+ (instancetype)sharedInstance
{
    static OBNAudioManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[OBNAudioManager alloc] init];
        }
    });
    return sharedInstance;
}
-(instancetype) init
{
    self = [super init];
    if(self)
    {
        // The Amazing Audio Engine-based audio controller
        _audioController = [[AEAudioController alloc]
                                initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                                inputEnabled:YES];
        BOOL result = [_audioController start:nil]; //blocking call - interesting
        _audioRecorder = nil;
        _audioPlayer = nil;
    }
    return self;
}

-(void) play: (NSString *) filePath
{
    NSRange fileName = [filePath rangeOfString:[filePath lastPathComponent]];
    NSRange path = NSMakeRange(0, filePath.length-fileName.length);
    NSMutableString *newName = [[NSMutableString alloc] initWithString:[filePath substringWithRange:path]];
    [newName appendString:@"proc.m4a"];

    NSURL *file = [NSURL fileURLWithPath:filePath];
    self.audioPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                            audioController:_audioController
                                             error:NULL];
    self.audioPlayer.completionBlock = ^{
        [self.audioRecorder finishRecording];
        [self.audioController removeOutputReceiver:self.audioRecorder];
        self.audioRecorder = nil;
    };
    
    /*AEAudioUnitFilter *reverb = [[AEAudioUnitFilter alloc]
                                     initWithComponentDescription:
                                 AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                 kAudioUnitType_Effect,kAudioUnitSubType_Reverb2)
                                     audioController:_audioController
                                     error:NULL];
    if ( reverb ) {
        // Assign a parameter value
        AudioUnitSetParameter(reverb.audioUnit,
                                  kAudioUnitScope_Global,
                                  0,
                                  kReverb2Param_DryWetMix,
                                  100.f,
                                  0);
            
        // Begin filtering
        [_audioController addFilter:reverb];
    }*/
    [_audioController addChannels:[NSArray arrayWithObjects:self.audioPlayer,nil]];

 }


-(void) addFilter: (OBFilter) filter  path:(NSString *) filePath
{
    switch(filter)
    {
        case kHelium:
        {
            AudioComponentDescription helium = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_FormatConverter, kAudioUnitSubType_NewTimePitch);
            
            AEAudioUnitFilter *heliumUnit = [[AEAudioUnitFilter alloc] initWithComponentDescription:helium
                                                                                    audioController:_audioController error:nil];
            
            if(!heliumUnit) NSLog(@"Trouble creating helium unit");
            AudioUnitSetParameter(heliumUnit.audioUnit, kNewTimePitchParam_Pitch,
                                  kAudioUnitScope_Global,0,
                                  -700.f, 0);
            [_audioController addFilter:heliumUnit];
            
            NSRange fileName = [filePath rangeOfString:[filePath lastPathComponent]];
            NSRange path = NSMakeRange(0, filePath.length-fileName.length);
            NSMutableString *newName = [[NSMutableString alloc] initWithString:[filePath substringWithRange:path]];
            [newName appendString:@"proc.m4a"];
            
            self.audioRecorder = [[AERecorder alloc] initWithAudioController:_audioController];
            [self.audioRecorder beginRecordingToFileAtPath:newName fileType:kAudioFileM4AType error:nil];
            [_audioController addOutputReceiver:self.audioRecorder];
            
            [self play:filePath];
            break;
        }
        case kReverb:
        {
            break;
        }
        case kAutoTune:
        {
            break;
        }
        case kSuperBass:
        {
            break;
        }
        default:
        {
            
        }
    }
}

-(void) addEffect: (OBEffect) effect
{
    
}

-(OBNSound *) record: (NSString *)filePath
{
    self.audioRecorder = [[AERecorder alloc] initWithAudioController:_audioController];
    OBNSound *recording = [[OBNSound alloc] init];
    recording.localUrl = filePath;
    
    
    NSError *error = NULL;
    
    // Receive both audio input and audio output. Note that if you're using
    // AEPlaythroughChannel, mentioned above, you may not need to receive the input again.
    
    if ( ![self.audioRecorder beginRecordingToFileAtPath:filePath
                                                fileType:kAudioFileM4AType
                                                   error:&error] ) {
        // Report error
        NSLog(@"Error initializing audio recorder");
        return nil;
    }
    
    [_audioController addInputReceiver:self.audioRecorder];
    return recording;
}

-(void) stop
{
    [self.audioController removeInputReceiver:self.audioRecorder];
    [self.audioRecorder finishRecording];
    self.audioRecorder = nil;
}

@end
