//
//  MainViewController.m
//  FacebookVideos
//
//  Created by user on 04/05/17.
//  Copyright © 2017 user. All rights reserved.
//

#import "MainViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AsyncImageView.h"
#import "VideoTableViewCell.h"
#import <AssetsLibrary/ALAsset.h>

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet AsyncImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileEmailLabel;
@property (weak, nonatomic) IBOutlet UIView *logoutButtonView;
@property (weak, nonatomic) IBOutlet UIView *indicatorBgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *videoListTableView;


@end

@implementation MainViewController
NSMutableArray *videoListArray;
int videoListCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    videoListArray = [[NSMutableArray alloc] init];
    [self setProfileDetails];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileDetails{
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,name,email,picture.width(150).height(150)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                _profileName.text = [result valueForKey:@"name"];
                _profileEmailLabel.text = [result valueForKey:@"email"];
                NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                [_profilePicImageView loadImageFromURL:[NSURL URLWithString:imageStringOfLoginUser]];
                FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
                [loginButton setFrame:_logoutButtonView.frame];
                loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_photos", @"user_videos", @"user_posts"];
                loginButton.delegate = self;
                [_logoutButtonView.superview addSubview:loginButton];
                [self setVideoList];
            }else{
                [self setProfileDetails];
            }
        }];
    }
}

- (void)setVideoList{
    if ([FBSDKAccessToken currentAccessToken]) {
        [_indicatorBgView setHidden:FALSE];
        [_activityIndicator startAnimating];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed" parameters:@{@"fields": @"id, message, created_time, type, object_id, story"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 [_indicatorBgView setHidden:TRUE];
                 [_activityIndicator stopAnimating];
                 NSMutableDictionary *json =[[NSMutableDictionary alloc] initWithDictionary:result];
                 
                 if ([json isKindOfClass:[NSMutableDictionary class]]){ //Added instrospection as suggested in comment.
                     NSMutableArray *jsonDataArray = [[NSMutableArray alloc] initWithArray:json[@"data"]];
                     if ([jsonDataArray isKindOfClass:[NSMutableArray class]]){//Added instrospection as suggested in comment.
                         
                         for (NSDictionary *dict in jsonDataArray) {
                             NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
                             
                             if([[dictionary objectForKey:@"type"] isEqualToString:@"video"]){
                                 [[[FBSDKGraphRequest alloc] initWithGraphPath:[[dictionary objectForKey:@"id"] stringByAppendingString:@"/attachments"] parameters:nil]
                                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          //NSLog(@"%@",dictionary);
                                          [dictionary setObject:[[[[result valueForKey:@"data"] valueForKey:@"media"] valueForKey:@"image"] valueForKey:@"src"] forKey:@"image_url"];
                                          
                                          [[[FBSDKGraphRequest alloc] initWithGraphPath:[[[[result valueForKey:@"data"] valueForKey:@"target"] valueForKey:@"id"] objectAtIndex:0]parameters:@{@"fields": @"id, source"}]
                                           startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                               if (!error) {
                                                   [dictionary setObject:[result valueForKey:@"source"]forKey:@"video_url"];
                                                   [videoListArray addObject:dictionary];
                                                   videoListCount = (int)[videoListArray count];
                                                   [_videoListTableView reloadData];
                                               }else{
                                                   [_videoListTableView reloadData];
                                               }
                                           }];
                                          
                                      }else{
                                          [_videoListTableView reloadData];
                                      }
                                  }];
                             }
                         }
                     }
                 }
                 
             }else{
                 NSLog(@"Error user:%@", error);
                 [self setVideoList];
             }
         }];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"Logout result %@ ",loginButton);
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return videoListCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"VideoCell";
    
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    id obj = [videoListArray objectAtIndex:indexPath.row];
    
    cell.storyLabel.text = [obj objectForKey:@"story"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //2010-12-01T21:35:43+0000
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    NSDate *date = [df dateFromString:[obj objectForKey:@"created_time"]];
    [df setDateFormat:@"eee MMM dd, yyyy hh:mm"];
    NSString *dateStr = [df stringFromDate:date];
    cell.timeLabel.text = dateStr;
    
    [cell.videoThumImageView loadImageFromURL:[NSURL URLWithString:[[obj objectForKey:@"image_url"] objectAtIndex:0]]];
    [cell.downloadButton setTag:indexPath.row];
    [cell.downloadButton addTarget:self action:@selector(downloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(IBAction)downloadVideo:(id)sender
{
    //download the file in a seperate thread.
    id obj = [videoListArray objectAtIndex:[sender tag]];
    
    [_indicatorBgView setHidden:FALSE];
    [_activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString *urlToDownload = [obj objectForKey:@"video_url"];
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        
        NSError* error = nil;
        
        NSData* urlData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"Data failed to load: %@", [error localizedDescription]);
        } else {
            NSLog(@"Data has loaded successfully.");
        }

        if (urlData)
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"FbVideos.mp4"];
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
                
                ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
                [assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:filePath]  completionBlock:^(NSURL *assetURL, NSError *error){
                    if(error) {
                        NSLog(@"error while saving to camera roll %@",[error localizedDescription]);
                    } else {
                        //For removing the back up copy from the documents directory
                        NSError *removeError = nil;
                        [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:filePath] error:&removeError];
                        NSLog(@"%@",[removeError localizedDescription]);
                    }
                }];
                
                [_indicatorBgView setHidden:TRUE];
                [_activityIndicator stopAnimating];
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Success"
                                              message:@"Video Successfully Downloaded"
                                              preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [self.navigationController popViewControllerAnimated:YES];
                                             
                                         }];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        
    });
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
