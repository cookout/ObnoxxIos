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
@property (nonatomic, strong) AEAudioController *audioController;

-(IBAction) play:(id) sender;
-(IBAction) record:(id) sender;

@end

@implementation OBNRecordViewController


-(IBAction) play:(id) sender
{
    
}

-(IBAction) record:(id) sender
{
    
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
