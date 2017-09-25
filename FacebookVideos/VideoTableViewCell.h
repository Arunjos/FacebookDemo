//
//  VideoTableViewCell.h
//  FacebookVideos
//
//  Created by user on 04/05/17.
//  Copyright © 2017 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface VideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *videoThumImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;


@end
