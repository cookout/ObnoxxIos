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



@interface OBNMessageViewController ()

@end

@implementation OBNMessageViewController

-(void) loadMessages
{
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    [server addObserver:self forKeyPath:@"soundsResponse" options:NSKeyValueChangeNewKey context:@"getSounds"];
    [server getSounds];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)response change:(NSString *)change context:(id) context
{
    if([context isEqualToString:@"getSounds"])
    {
        // Check if request succeeded
        OBNServerCommunicator *server = response;
        OBNState *appState = [OBNState sharedInstance];
        int success = ((NSString *)[server.soundsResponse valueForKey:@"success"]).intValue;
        
        if(success)
        {
            // Populate the local data model with results
            appState.deliveries = [server.soundsResponse valueForKey:@"soundDeliveries"];
            appState.users = [server.soundsResponse valueForKey:@"users"];
            appState.sounds = [server.soundsResponse valueForKey:@"sounds"];
            [appState saveToDisk];
            [self.tableView reloadData];
        }
        else
        {
            // Something was wrong at this step
        }
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    OBNState *appState = [OBNState sharedInstance];
    if(appState.deliveries)
      return [OBNState sharedInstance].deliveries.count;
    
    else return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User selected a sound, play it back
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *delivery = appState.deliveries[indexPath.row];
    NSMutableArray *sounds = appState.sounds;
    
    NSString *soundURL;
    NSString *soundId = [delivery valueForKey:@"soundId"];
    NSString *s;
    
    
    int i=0;
    for(i=0;i<sounds.count;i++)
    {
        s = [sounds[i] valueForKey:@"id"];
        if([soundId isEqualToString:s])
        {
            NSLog(@"here");
            soundURL = [sounds[i] valueForKey:@"soundFileUrl"];
            break;
        }
    }
    OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSURL  *url = [NSURL URLWithString:soundURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        NSString  *filePath;
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"sound.m4a"];
            [urlData writeToFile:filePath atomically:YES];
        }
        [audioManager play:filePath];
    });
    
}


@end
