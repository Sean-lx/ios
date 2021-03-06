//
//  TBC.m
//  OwnTracks
//
//  Created by Christoph Krey on 21.06.15.
//  Copyright © 2015-2018 OwnTracks. All rights reserved.
//

#import "TabBarController.h"
#import "Settings.h"
#import "UIColor+WithName.h"
#import "OwnTracksAppDelegate.h"
#import "CoreData.h"

@interface TabBarController ()
@property (strong, nonatomic) UIViewController *featuredVC;
@property (nonatomic) BOOL warning;
@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    for (UIViewController *vc in self.viewControllers) {
        if (vc.tabBarItem.tag == 98) {
            self.featuredVC = vc;
        }
    }
    OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate addObserver:self
               forKeyPath:@"action"
                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                  context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"action"]) {
        [self performSelectorOnMainThread:@selector(adjust) withObject:nil waitUntilDone:NO];
    }
}

- (void)adjust {
        
    if (self.featuredVC) {
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
        
        OwnTracksAppDelegate *delegate = (OwnTracksAppDelegate *)[UIApplication sharedApplication].delegate;

        if (delegate.action) {
            if (![viewControllers containsObject:self.featuredVC]) {
                [viewControllers insertObject:self.featuredVC atIndex:viewControllers.count];
                self.featuredVC.tabBarItem.badgeValue = NSLocalizedString(@"!",
                                                                          @"New featured content indicator");
            }
        } else {
            if ([viewControllers containsObject:self.featuredVC]) {
                [viewControllers removeObject:self.featuredVC];
            }
        }
        [self setViewControllers:viewControllers animated:TRUE];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.warning && [Settings intForKey:@"mode" inMOC:CoreData.sharedInstance.mainMOC
                        ] == CONNECTION_MODE_PUBLIC) {
        self.warning = TRUE;
        [self performSegueWithIdentifier:@"login" sender:nil];
    }
}


@end
