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
#import "OBNConversationViewController.h"

@implementation OBNMessageViewController

- (void)loadMessages {
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    OBNState *appState = [OBNState sharedInstance];
    
    [appState addObserver:self
             forKeyPath:@"uniqueSortedSenderList"
                options:NSKeyValueObservingOptionNew
                context:nil];
    [server getSounds];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)appState
                        change:(NSString *)change
                       context:(void *)context {

    // Check if request succeeded
    /*NSDictionary *soundsResponse =
            ((OBNServerCommunicator *)serverCommunicator).soundsResponse;
    OBNState *appState = [OBNState sharedInstance];
    int success = ((NSString *)[soundsResponse valueForKey:@"success"]).intValue;*/
    [self.tableView reloadData];
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
    if (appState.uniqueSortedSenderList) {
        return [appState.uniqueSortedSenderList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    OBNState *appState = [OBNState sharedInstance];
    
    NSString *userId = appState.uniqueSortedSenderList[indexPath.row];
    NSString *userName;
    
    for(int i=0;i<appState.users.count;i++)
    {
        if([[appState.users[i] valueForKey:@"id"] isEqualToString:userId])
        {
            userName = [appState.users[i] valueForKey:@"name"];
            break;
        }
    }
    
    // The id is actually a phone number that this user sent a message
    // to.
    if(!userName)
        userName = userId;
    
    cell.textLabel.text = userName;
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
    
    OBNState *appState = [OBNState sharedInstance];

    OBNConversationViewController *conversation = [[OBNConversationViewController alloc] init];
    conversation.sender = appState.uniqueSortedSenderList[indexPath.row];
    
    [self presentViewController:conversation animated:YES completion:nil];
    
}

@end
