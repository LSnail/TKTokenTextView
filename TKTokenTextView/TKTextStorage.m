//
//  TKTextStorage.m
//  New Momento
//
//  Created by 韩驰 on 15/9/25.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import "TKTextStorage.h"

@implementation TKTextStorage
{
    NSMutableAttributedString *_imp;
}

- (NSDictionary *)setDefaultAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 9;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9]
                                 };
    return attributes;
}


- (id)init {
    self = [super init];
    
    if (self) {
        _imp = [NSMutableAttributedString new];
    }
    
    return self;
}

#pragma mark - Reading Text
/**
 *  required getter：返回保存的字符串
 */
- (NSString *)string {
    return _imp.string;
}

/**
 *  required getter：获取指定范围内的文字属性--字典对象
 *
 *  @param location 开始的位置（index）
 *  @param range    被渲染的range
 *
 *  @return 渲染属性的字典对象
 */
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_imp attributesAtIndex:location effectiveRange:range];
}

#pragma mark - Text Editing

/**
 *  required setter：修改指定范围内的文字
 *
 *  @param range 被替换的range
 *  @param str   替换后的string
 */
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    // normal replace
    [_imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    //NSLog(@"textView text is :%@ length:%lu",self.string,self.string.length);
    
//    static NSDataDetector *linkDetector;
//    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:NULL];
//    
//    // Clear text color of edited range
//    NSRange paragaphRange = [self.string paragraphRangeForRange: NSMakeRange(range.location, str.length)];
//    [self removeAttribute:NSLinkAttributeName range:paragaphRange];
//    [self removeAttribute:NSBackgroundColorAttributeName range:paragaphRange];
//    [self removeAttribute:NSUnderlineStyleAttributeName range:paragaphRange];
//    
//    // Find all iWords in range
//    [linkDetector enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//        // Add red highlight color
//        [self addAttribute:NSLinkAttributeName value:result.URL range:result.range];
//        [self addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:result.range];
//        [self addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:result.range];
//    }];
    
    
    
}

/**
 *  required setter：设置指定范围内的文字属性
 *
 *  @param attrs 属性字典
 *  @param range 渲染range
 */
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}


#pragma mark - Syntax add Highlighted

/**
 *  每次文本存储有修改时，这个方法都自动被调用。每次编辑后，NSTextStorage 会用这个方法来清理字符串。
 *  例如，有些字符无法用选定的字体显示时，文本存储使用一个可以显示它们的字体来进行替换。
 */
- (void)processEditing {
    
//    static NSString *keyWordsWith;
//    static NSString *keyWordsAt;
//    
    if([self.string hasSuffix:@" with "] || [self.string hasSuffix:@" With "] ||
       [self.string hasPrefix:@"with "] || [self.string hasPrefix:@"With "]) {
        _searchStatus = SEARCH_WITH_NAMES;
    }else if ([self.string hasSuffix:@" at "] || [self.string hasSuffix:@" At "] ||
              [self.string hasPrefix:@"at "] || [self.string hasPrefix:@"At "]) {
        _searchStatus = SEARCH_AT_LOCATIONS;
    } else {
        _searchStatus = SEARCH_STATUS_NONE;
    }

    
    
    [super processEditing];
    
}


@end
