//
//  DynamicPageViewController.h
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


#import <UIKit/UIKit.h>
#import "IdentifiableContent.h"

@interface DynamicPageViewController : UIPageViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

// All the content view controllers must adopt IdentifiableContent protocol

@property (nonatomic)NSMutableArray*classNamesList;             // You can resolve from class
@property (nonatomic)NSMutableArray*storyBoardIdsList;          // Or use a storyboard based sequence
@property (nonatomic)NSMutableArray*sequenceInstanceIdentifier; // In both case you must set an identifier for each item.
- (void)configure:(UIViewController<IdentifiableContent>*)contentViewController atIndex:(NSUInteger)index;

#pragma Mark - Programmatic navigation

- (void)nextPage;
- (void)previousPage;

#pragma Mark - CurrentIndex

- (void)indexHasChangedTo:(NSUInteger)index;


@end
