//
//  ViewController.m
//  FacebookVideos
//
//  Created by user on 27/04/17.
//  Copyright © 2017 user. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        loginButton.center = self.view.center;
        loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_photos", @"user_videos", @"user_posts"];
        loginButton.delegate = self;
        [self.view addSubview:loginButton];
        // Do any additional setup after loading the view, typically from a nib.
    }
}
-(void)viewDidAppear:(BOOL)animated{
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"DetailsPageSegue" sender:self];
    }
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error{
    [self performSegueWithIdentifier:@"DetailsPageSegue" sender:self];
    NSLog(@"Login result %@ error %@",result,error);
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"Logout result %@ ",loginButton);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
