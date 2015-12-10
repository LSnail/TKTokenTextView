//
//  TKTextStorage.h
//  New Momento
//
//  Created by 韩驰 on 15/9/25.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SEARCH_STATUS_NONE = 0,
    SEARCH_BEGIN = 1,
    SEARCH_END,
    SEARCH_WITH_NAMES,
    SEARCH_AT_LOCATIONS
}SEARCH_STATUS;

@interface TKTextStorage : NSTextStorage

@property (nonatomic,assign) SEARCH_STATUS searchStatus;

@end
