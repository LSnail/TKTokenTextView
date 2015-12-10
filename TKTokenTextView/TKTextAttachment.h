//
//  TKTextAttachment.h
//  New Momento
//
//  Created by 韩驰 on 15/10/12.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKTextAttachment : NSTextAttachment

@property (nonatomic,strong) NSString *theId;
@property (nonatomic,strong) NSString *theName;
@property (nonatomic,strong) NSString *type;

@property(nonatomic, readonly) CGSize expectedSize;



@end
