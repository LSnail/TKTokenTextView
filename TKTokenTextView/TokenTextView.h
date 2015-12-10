//
//  TokenTextView.h
//  New Momento
//
//  Created by 韩驰 on 15/10/23.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TokenTextView : UITextView <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSAttributedString *blank;


- (UIImage *)setTagImageWithText:(NSString *)text;

- (void)addTagWithString:(NSString *)string andId:(NSString *)idString andType:(NSString *)type;

- (CGRect) frameOfTagForIdentifier:(NSString *)identifier;

- (BOOL) attachmentExistsWithIdentifier:(NSString *)identifier;

- (BOOL) shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void) clearAllTags;

@end
