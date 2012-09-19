//
//  ViewController.m
//  ListviewImagePresenter
//
//  Created by Peter Cen on 12-09-19.
//  Copyright (c) 2012 Peter Cen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#define kImageView 99

@interface ViewController ()

@end

@implementation ViewController


- (void) dismissImageView {
    //Move image from scrollview to the static view
    UIScrollView *scrollView = (UIScrollView *)popupImageView.superview;
    [scrollView setDelegate:nil];
    [popupImageView retain];
    [popupImageView removeFromSuperview];
    
    //We calculate the frame of the image's frame based on the scrollview's frame with the appropriate zoomScale
    [popupImageView setFrame:CGRectMake(scrollView.contentOffset.x/scrollView.zoomScale*-1, scrollView.contentOffset.y/scrollView.zoomScale*-1, popupImageView.frame.size.width*scrollView.zoomScale, popupImageView.frame.size.height*scrollView.zoomScale)];
    [popupImageViewContainer addSubview:popupImageView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    //Rescale the image using animation to the saved frame
    CGRect bounds = savedRect;
    UIImage *image = popupImageView.image;
    [UIView transitionWithView:self.view
                      duration:.2
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        if (image.size.width > image.size.height/savedRect.size.height*savedRect.size.width) {
                            [popupImageView setFrame:CGRectMake(bounds.size.width/2+bounds.origin.x-image.size.width/2, bounds.origin.y, image.size.width, bounds.size.height)];
                            
                        } else {
                            [popupImageView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y+bounds.size.height/2-(bounds.size.width/image.size.width*image.size.height)/2, bounds.size.width, bounds.size.width/image.size.width*image.size.height)];
                        }
                        
                    }
     //Fade out the views and remove them from memory
                    completion:^(BOOL finished){
                        [UIView transitionWithView:self.view
                                          duration:.5
                                           options:UIViewAnimationOptionCurveEaseOut
                                        animations:^{
                                            [popupImageViewContainer setAlpha:0];
                                            [popupImageView setAlpha:0];
                                        }
                                        completion:^(BOOL finished){
                                            [popupImageView removeFromSuperview];
                                            [popupImageView release];
                                            popupImageView = nil;
                                            [popupImageViewContainer removeFromSuperview];
                                            popupImageViewContainer = nil;
                                            
                                        }];
                    }];
    
    
}

- (void) viewImage:(UIImage *)image view:(UIView *)origin viewBounds:(CGRect)viewBounds {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
    CGRect tabViewBounds = window.bounds;
    
    //Depending on your view hierachy, you may need to tweak the origin of the window frame
    tabViewBounds.origin.y -= 20;
    tabViewBounds.size.height += 20;
    popupImageViewContainer = [[UIView alloc] initWithFrame:tabViewBounds];
    [popupImageViewContainer setBackgroundColor:[UIColor blackColor]];
    [popupImageViewContainer setAlpha:0];
    [window addSubview:popupImageViewContainer];
    [popupImageViewContainer release];
    
    CGRect bounds = [origin convertRect:viewBounds toView:popupImageViewContainer];
    savedRect = bounds;
    
    
    //Place image in UIImageView with frame transformed from tableview
    popupImageView = [[UIImageView alloc] initWithImage:image];
    popupImageView.contentMode = UIViewContentModeScaleAspectFill;
    popupImageView.clipsToBounds = YES;
    popupImageView.tag = kImageView;
    if (image.size.width > image.size.height/savedRect.size.height*savedRect.size.width) {
        [popupImageView setFrame:CGRectMake(bounds.size.width/2+bounds.origin.x-image.size.width/2, bounds.origin.y, image.size.width, bounds.size.height)];
    } else {
        [popupImageView setFrame:CGRectMake(bounds.origin.x, bounds.origin.y+bounds.size.height/2-(bounds.size.width/image.size.width*image.size.height)/2, bounds.size.width, bounds.size.width/image.size.width*image.size.height)];
    }
    [popupImageView setAlpha:0];
    [popupImageViewContainer addSubview:popupImageView];
    
    [UIView transitionWithView:self.view
                      duration:.5
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        
                        [popupImageView setAlpha:1];
                        [popupImageViewContainer setAlpha:1];
                    }
                    completion:^(BOOL finished){
                        [UIView transitionWithView:self.view
                                          duration:.2
                                           options:UIViewAnimationOptionCurveEaseOut
                                        animations:^{
                                            popupImageView.contentMode = UIViewContentModeScaleAspectFit;
                                            [popupImageView setFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
                                            
                                        }
                         //Once animation is complete, we remove the image and place it in a scrollview so users can zoom
                                        completion:^(BOOL finished){
                                            UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:popupImageViewContainer.bounds];
                                            scroll.userInteractionEnabled = YES;
                                            scroll.maximumZoomScale = 2.0;
                                            scroll.minimumZoomScale = 0.99999;
                                            scroll.bouncesZoom = NO;
                                            scroll.delegate = self;
                                            [popupImageView removeFromSuperview];
                                            [scroll addSubview:popupImageView];
                                            [popupImageView setUserInteractionEnabled:YES];
                                            [popupImageView release];
                                            //Users can dismiss the popup through the tapping gesture
                                            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImageView)];
                                            [scroll addGestureRecognizer:tapGesture];
                                            [tapGesture release];
                                            [popupImageViewContainer addSubview:scroll];
                                        }];
                    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *imageView = [scrollView viewWithTag:kImageView];
	if (imageView) {
        return imageView;
    }
	return nil;
	
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    //Close the imageview if the user tries to zoom out, this is optional
    UIView *view99 = [scrollView viewWithTag:kImageView];
	if (view99 && view == view99) {
        if (scale < 1) {
            [self dismissImageView];
            [scrollView setZoomScale:1 animated:YES];
        }
        
    }
}

- (void) viewImage:(UIButton *)button {
    [self viewImage:[images objectAtIndex:button.tag] view:button viewBounds:CGRectMake(6, 5, 300, 200)];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    UIButton *imageBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBgButton setFrame:CGRectMake(4, 4, 313, 213)];
    [imageBgButton setTag:indexPath.row];
    [imageBgButton addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [imageBgButton setBackgroundImage:[[UIImage imageNamed:@"oll4backgroundimage.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateNormal];
    [imageBgButton setBackgroundImage:[[UIImage imageNamed:@"oll4backgroundimage.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateHighlighted];
    [cell.contentView addSubview:imageBgButton];
    
    UIImageView *editAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(6, 5, 300, 200)];
    [editAvatar setImage:[images objectAtIndex:indexPath.row]];
    editAvatar.contentMode = UIViewContentModeScaleAspectFill;
    editAvatar.clipsToBounds = YES;
    [editAvatar setTag:999];
    [imageBgButton addSubview:editAvatar];
    [editAvatar release];
    // Configure the cell...
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 221;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    images = [[NSArray alloc ]initWithObjects:[UIImage imageNamed:@"park.png"], [UIImage imageNamed:@"beer.png"], [UIImage imageNamed:@"wall.png"], nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
