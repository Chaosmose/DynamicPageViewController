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
    self.showPageCounter=YES;
    self.classNamesList=[NSMutableArray array];
    self.storyBoardIdsList=[NSMutableArray array];
    self.sequenceInstanceIdentifier=[NSMutableArray array];
    self.delegate=self;
    self.dataSource=self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma Mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger idx=[self _indexOfViewController:(UIViewController<IdentifiableContent>*)viewController];
    if(idx==NSNotFound || idx==0){
        return nil;
    }
    return [self _contentViewControllerAtIndex:idx-1];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger idx=[self _indexOfViewController:(UIViewController<IdentifiableContent>*)viewController];
    if(idx==NSNotFound || (idx>[_sequenceInstanceIdentifier count]-2)){
        return nil;
    }
    return [self _contentViewControllerAtIndex:idx+1];
}

-(UIViewController<IdentifiableContent>*)_contentViewControllerAtIndex:(NSUInteger)index{
    UIViewController<IdentifiableContent>*contentViewController=nil;
    if([self _useStoryBoard]){
        contentViewController=[self.storyboard instantiateViewControllerWithIdentifier:[_storyBoardIdsList objectAtIndex:index]];
    }else{
        Class currentClass=NSClassFromString([_classNamesList objectAtIndex:index]);
        contentViewController=[[currentClass alloc] init];
    }
    [self configure:contentViewController atIndex:index];
    return contentViewController;
}

- (BOOL)_useStoryBoard{
    return ([_storyBoardIdsList count]>[_classNamesList count]);
}

- (NSUInteger)_indexOfViewController:(UIViewController<IdentifiableContent>*)viewController{
    UIViewController<IdentifiableContent>*casted=(UIViewController<IdentifiableContent>*)viewController;
    NSString *identifier=[casted indexIdentifier];
    NSUInteger idx=[_sequenceInstanceIdentifier indexOfObject:identifier];
    return idx;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    if(!_showPageCounter){
        return 0;
    }
    return [_sequenceInstanceIdentifier count];
  
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    if(!_showPageCounter){
        return 0;
    }
    UIViewController<IdentifiableContent>*currentVc=[self _currentViewController];
    // We do return the index of the current view controller.
    if(currentVc){
        return [self.sequenceInstanceIdentifier indexOfObject:currentVc.indexIdentifier];
    }

}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    [self _changeIndexFor:[self _currentViewController]];
}

#pragma mark -

- (void)configure:(UIViewController<IdentifiableContent>*)contentViewController atIndex:(NSUInteger)index{
    if(![contentViewController conformsToProtocol:@protocol(IdentifiableContent)]){
        [NSException raise:@"DynamicPageViewController"
                    format:@"contentViewController %@ must conform to IdentifiableContent",NSStringFromClass([contentViewController class])];
    }
    // We set up the identifier
    [contentViewController setIndexIdentifier:[self.sequenceInstanceIdentifier objectAtIndex:index]];
}

- (void)nextPage{
    DynamicPageViewController *__weak weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController<IdentifiableContent>*target=(UIViewController<IdentifiableContent>*)[weakSelf pageViewController:weakSelf viewControllerAfterViewController:[weakSelf _currentViewController]];
        if(target){
            [weakSelf setViewControllers:@[target]
                               direction:UIPageViewControllerNavigationDirectionForward
                                animated:YES
                              completion:^(BOOL finished) {
                                  [weakSelf _changeIndexFor:target];
                              }];
        }
    });
    
    
    
}
- (void)previousPage{
    DynamicPageViewController *__weak weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController<IdentifiableContent>*target=(UIViewController<IdentifiableContent>*)[weakSelf pageViewController:weakSelf viewControllerBeforeViewController:[weakSelf _currentViewController]];
        if(target){
            [weakSelf setViewControllers:@[target] direction:UIPageViewControllerNavigationDirectionForward animated:YES
                              completion:^(BOOL finished) {
                                  [weakSelf _changeIndexFor:target];
                              }];
        }
    });
}

- (void)_changeIndexFor:(UIViewController<IdentifiableContent>*)viewController{
    NSString*identifier=viewController.indexIdentifier;
    NSUInteger idx=[_sequenceInstanceIdentifier indexOfObject:identifier];
    [self indexHasChangedTo:idx];
}

- (void)indexHasChangedTo:(NSUInteger)index{
    
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
