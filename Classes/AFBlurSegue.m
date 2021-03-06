//
//  AFBlurSegue.m
//  AFBlurSegue-Demo
//
//  Created by Alvaro Franco on 6/5/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFBlurSegue.h"
#import "UIImage+ImageEffects.h"

@implementation AFBlurSegue

-(id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    
    self = [super initWithIdentifier:identifier source:source destination:destination];
    
    if (self) {
        _blurRadius = 20;
        _tintColor = [UIColor clearColor];
        _saturationDeltaFactor = 0.5;
    }
    
    return self;
}

-(void)perform {
    
    UIViewController *sourceController = self.sourceViewController;
    UIViewController *destinationController = self.destinationViewController;
    UIViewController *realDestinationViewController = nil;
	
    UIImage *background = [UIImage new];
    
	if ([destinationController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *destnavigation = (id)destinationController;
		
		realDestinationViewController = [destnavigation.viewControllers firstObject];
	}
	
    if ([sourceController isKindOfClass:[UITableViewController class]]) {
        
        UIView *viewToRender = [(UITableViewController *)sourceController tableView];
        CGPoint contentOffset = [[(UITableViewController *)sourceController tableView]contentOffset];
        
        UIGraphicsBeginImageContext(viewToRender.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, -contentOffset.y);
        [viewToRender.layer renderInContext:context];
        background = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        
        UIGraphicsBeginImageContextWithOptions(sourceController.view.bounds.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [sourceController.view.layer renderInContext:context];
        background = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    switch ([[UIApplication sharedApplication]statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
            background = [UIImage imageWithCGImage:background.CGImage scale:1 orientation:UIImageOrientationUp];
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            background = [UIImage imageWithCGImage:background.CGImage scale:1 orientation:UIImageOrientationDown];
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            background = [UIImage imageWithCGImage:background.CGImage scale:1 orientation:UIImageOrientationLeft];
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            background = [UIImage imageWithCGImage:background.CGImage scale:1 orientation:UIImageOrientationRight];
            break;
            
        default:
            break;
    }
    
    UIImageView *blurredBackground = [[UIImageView alloc]initWithImage:[background applyBlurWithRadius:_blurRadius tintColor:_tintColor saturationDeltaFactor:_saturationDeltaFactor maskImage:nil]];
    
    CGRect backgroundRect = [sourceController.view convertRect:sourceController.view.window.bounds fromView:Nil];
    
    if (destinationController.modalTransitionStyle == UIModalTransitionStyleCoverVertical) {
        blurredBackground.frame = CGRectMake(0, -backgroundRect.size.width, backgroundRect.size.width, backgroundRect.size.height);
    } else {
        blurredBackground.frame = CGRectMake(0, 0, backgroundRect.size.width, backgroundRect.size.height);
    }
    
	if (realDestinationViewController != nil) {
		realDestinationViewController.view.backgroundColor = [UIColor clearColor];
		//realDestinationViewController.navigationController.navigationBar.tintColor = _tintColor;
		
		if ([realDestinationViewController isKindOfClass:[UITableViewController class]]) {
			[[(UITableViewController *)realDestinationViewController tableView]setBackgroundView:blurredBackground];
		} else {
			[realDestinationViewController.view addSubview:blurredBackground];
			[realDestinationViewController.view sendSubviewToBack:blurredBackground];
		}
		
	} else {
		
		destinationController.view.backgroundColor = [UIColor clearColor];
		
		if ([destinationController isKindOfClass:[UITableViewController class]]) {
			[[(UITableViewController *)destinationController tableView]setBackgroundView:blurredBackground];
		} else {
			[destinationController.view addSubview:blurredBackground];
			[destinationController.view sendSubviewToBack:blurredBackground];
		}
    }
	
    [sourceController presentViewController:destinationController animated:YES completion:nil];
    
    [destinationController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [UIView animateWithDuration:[context transitionDuration] animations:^{
            blurredBackground.frame = CGRectMake(0, 0, backgroundRect.size.width, backgroundRect.size.height);
        }];
    } completion:nil];
}

@end