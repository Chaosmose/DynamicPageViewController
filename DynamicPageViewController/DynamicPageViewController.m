//
//  DynamicPageViewController.m
//  DynamicPageViewController
//
// This file is part of "DynamicPageViewController"
//
// "DynamicPageViewController" is free software: you can redistribute it and/or modify
// it under the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// "DynamicPageViewController" is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU LESSER GENERAL PUBLIC LICENSE for more details.
//
// You should have received a copy of the GNU LESSER GENERAL PUBLIC LICENSE
// along with "DynamicPageViewController"  If not, see <http://www.gnu.org/licenses/>

//  Created by Benoit Pereira da Silva on 27/05/2014.
//  Copyright (c) 2014 http://pereira-da-silva.com. All rights reserved.


#import "DynamicPageViewController.h"

@interface DynamicPageViewController ()

@end

@implementation DynamicPageViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.classNamesList=[NSMutableArray array];
    self.storyBoardIdsList=[NSMutableArray array];
    self.sequenceInstanceIdentifier=[NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([self.classNamesList count]!=[self.sequenceInstanceIdentifier count]){
        [NSException raise:@"DynamicPageViewController" format:@"[self.classNamesList count]==[self.sequenceInstanceIdentifier count]"];
    }
    self.delegate=self;
    self.dataSource=self;
}

#pragma Mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSString*className=NSStringFromClass([viewController class]);
    NSUInteger idx=[_classNamesList indexOfObject:className];
    if(idx==NSNotFound || idx==0){
        return nil;
    }
    UIViewController<IdentifiableContent>*contentViewController=[self.storyboard instantiateViewControllerWithIdentifier:[_storyBoardIdsList objectAtIndex:idx-1]];
    [self configure:contentViewController atIndex:idx-1];
    return contentViewController;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSString*className=NSStringFromClass([viewController class]);
    NSUInteger idx=[_classNamesList indexOfObject:className];
    if(idx==NSNotFound || (idx==[_classNamesList count]-1)){
        return nil;
    }
    UIViewController<IdentifiableContent>*contentViewController=[self.storyboard instantiateViewControllerWithIdentifier:[_storyBoardIdsList objectAtIndex:idx+1]];
    [self configure:contentViewController atIndex:idx+1];
    return contentViewController;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [_classNamesList count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    UIViewController<IdentifiableContent>*currentVc=[self _currentViewController];
    // We do return the index of the current view controller.
    if(currentVc)
        return [self.sequenceInstanceIdentifier indexOfObject:currentVc.indexIdentifier];
    return 0;
}

#pragma mark -

- (void)configure:(UIViewController<IdentifiableContent>*)contentViewController atIndex:(NSUInteger)index{
    if(![contentViewController conformsToProtocol:@protocol(IdentifiableContent)]){
        [NSException raise:@"DynamicPageViewController" format:@"contentViewController %@ must conform to IndexableInASequence",NSStringFromClass([contentViewController class])];
    }
    // We set up the identifier
    [contentViewController setIndexIdentifier:[self.sequenceInstanceIdentifier objectAtIndex:index]];
}

- (void)nextPage{
    DynamicPageViewController *__weak weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController*target=[weakSelf pageViewController:weakSelf viewControllerAfterViewController:[weakSelf _currentViewController]];
        [weakSelf setViewControllers:@[target]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:YES
                      completion:^(BOOL finished) {
                          }];
    });

    
    
}
- (void)previousPage{
    UIViewController*target=[self pageViewController:self viewControllerBeforeViewController:[self _currentViewController]];
    [self setViewControllers:@[target] direction:UIPageViewControllerNavigationDirectionForward animated:YES
                  completion:^(BOOL finished) {
                      
                  }];
}


- (void)goToPage:(NSInteger)pageIndex{
    
}

- (UIViewController<IdentifiableContent>*)_currentViewController{
    if([self.viewControllers count]==0){
        return nil;
    }
    return[self.viewControllers objectAtIndex:([self.viewControllers count]-1)];
}


#pragma  mark - 

-(BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}




@end
