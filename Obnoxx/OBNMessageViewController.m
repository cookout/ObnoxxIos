//
//  OBNMessageViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/6/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNMessageViewController.h"
#import "OBNServerCommunicator.h"
#import "OBNAudioManager.h"
#import "OBNState.h"
#import "OBNAudioManager.h"

@implementation OBNMessageViewController

- (void)loadMessages {
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    [server addObserver:self
             forKeyPath:@"soundsResponse"
                options:NSKeyValueObservingOptionNew
                context:nil];
    [server getSounds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)serverCommunicator
                        change:(NSString *)change
                       context:(void *)context {
    // Check if request succeeded
    NSDictionary *soundsResponse =
            ((OBNServerCommunicator *)serverCommunicator).soundsResponse;
    OBNState *appState = [OBNState sharedInstance];
    int success = ((NSString *)[soundsResponse valueForKey:@"success"]).intValue;
        
    if (success) {
        // Populate the local data model with results
        appState.deliveries = [soundsResponse valueForKey:@"soundDeliveries"];
        appState.users = [soundsResponse valueForKey:@"users"];
        appState.sounds = [soundsResponse valueForKey:@"sounds"];
        [appState saveToDisk];
        [self.tableView reloadData];
    } else {
        // Something was wrong at this step
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
         numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    OBNState *appState = [OBNState sharedInstance];
    if (appState.deliveries) {
        return [OBNState sharedInstance].deliveries.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    OBNState *appState = [OBNState sharedInstance];
    
    NSDictionary *delivery = appState.deliveries[indexPath.row];
    cell.textLabel.text = [delivery valueForKey:@"deliveryDateTime"];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // User selected a sound, play it back
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *delivery = appState.deliveries[indexPath.row];
    NSMutableArray *sounds = appState.sounds;
    
    NSString *soundURL;
    NSString *soundId = [delivery valueForKey:@"soundId"];

    for (int i = 0; i < sounds.count; i++) {
        NSString *s = [sounds[i] valueForKey:@"id"];
        if ([soundId isEqualToString:s]) {
            NSLog(@"here");
            soundURL = [sounds[i] valueForKey:@"soundFileUrl"];
            break;
        }
    }
    OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:soundURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        NSString *filePath;
        if (urlData) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(
                    NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            filePath = [NSString stringWithFormat:@"%@/%@",
                    documentsDirectory,@"sound.m4a"];
            [urlData writeToFile:filePath atomically:YES];
        }
        [audioManager play:filePath isRecording:NO filter:nil];
    });
}

@end
