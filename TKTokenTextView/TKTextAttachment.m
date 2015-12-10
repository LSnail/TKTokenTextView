//
//  TKTextAttachment.m
//  New Momento
//
//  Created by 韩驰 on 15/10/12.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import "TKTextAttachment.h"

@implementation TKTextAttachment
- (instancetype) initWithbounds:(CGRect)bounds {
    self = [super init];
    if (self) {
        _expectedSize = bounds.size;
        self.bounds = bounds;
    }
    return self;
}


- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
{
    CGFloat width = lineFrag.size.width;
    //NSLog(@"%f",width);
    float scalingFactor = 1.0;
    CGSize imageSize = [self.image size];
    if (width < imageSize.width)
        scalingFactor = width / imageSize.width;
    CGRect rect = CGRectMake(0, -12, imageSize.width * scalingFactor, imageSize.height * scalingFactor);
    
    _expectedSize = rect.size;
    return rect;
}


@end
