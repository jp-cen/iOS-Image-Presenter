//
//  ViewController.h
//  ListviewImagePresenter
//
//  Created by Peter Cen on 12-09-19.
//  Copyright (c) 2012 Peter Cen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController
{
    UIImageView *popupImageView;
    UIView *popupImageViewContainer;
    CGRect savedRect;
    NSArray *images;
}
- (void) viewImage:(UIImage *)image view:(UIView *)origin viewBounds:(CGRect)viewBounds;
@end
