//
//  TokenTextView.m
//  New Momento
//
//  Created by 韩驰 on 15/10/23.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import "TokenTextView.h"
#import "TKTextAttachment.h"
#import "Masonry.h"

#define DEFAULT_TEXT_ATTRIBUTES [self setDefaultAttributes]
#define DEFAULT_TITLE_HEIGTH                    60.0f
#define DEFAULT_TITLEVIEW_HEIGHT                42.0
#define DEFAULT_MAX_HEIGHT                      90.0
#define TAG_TEXT_INSET                          10.0f
#define TAG_HEIGHT                              33.0f
#define LINE_SPACING                            9
@interface TokenTextView ()

@property (nonatomic,strong) UIImageView    *highlightedTagView;
@property (nonatomic,assign) NSRange        shouldDeleteTagRange;
@property (nonatomic,strong) NSMutableArray *tagList;/**< an array that keeps all the tags' ID */

@end

@implementation TokenTextView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (NSMutableArray *)tagList {
    if (!_tagList) {
        _tagList = [NSMutableArray arrayWithCapacity:0];
    }return _tagList;
}

- (UIImageView *)highlightedTagView {
    if (!_highlightedTagView) {
        _highlightedTagView = [[UIImageView alloc] init];
    }return _highlightedTagView;
}

- (NSDictionary *)setDefaultAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = LINE_SPACING;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9]
                                 };
    return attributes;
}

// --------------------------------------------
#pragma mark - Tag Methods -
// --------------------------------------------
/**
 *  check all the tag, and then add their IDs to the tagList
 */
- (void) calculateAll {
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<self.tagList.count + 20; i++) {
        if ([self attachmentExistsWithIdentifier:[NSString stringWithFormat:@"%d",i]]) {
            [tmpArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    NSSet *set = [NSSet setWithArray:tmpArr];
    self.tagList = [[set allObjects] copy];
    //NSLog(@"%@",self.tagList);
}
/**
 *  add a tag with parameters
 *
 *  @param string   tag's title
 *  @param idString tag's id, it's the only one
 *  @param type     can add different tags with different types
 */
- (void)addTagWithString:(NSString *)string andId:(NSString *)idString andType:(NSString *)type{
     _blank = [[NSAttributedString alloc] initWithString:@" " attributes:DEFAULT_TEXT_ATTRIBUTES];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    TKTextAttachment *aTag =[[TKTextAttachment alloc] initWithData:nil ofType:type];
    aTag.image   = [self setTagImageWithText:string];
    aTag.theId   = idString;
    aTag.theName = string;
    aTag.type    = type;
    
    NSAttributedString *text=[NSAttributedString attributedStringWithAttachment:aTag];
    [str appendAttributedString:_blank];
    [str appendAttributedString:text];
    //[str insertAttributedString:text atIndex:_tokenTextView.selectedRange.location];
    NSLog(@"added a tag  name:%@, id:%@, type:%@",aTag.theName,aTag.theId,aTag.type);
    [str appendAttributedString:_blank];
 
    self.attributedText=str;
}
/**
 *  set a tag's background image for normal state
 *
 *  @param text tag's titile
 *
 *  @return background image
 */
- (UIImage *)setTagImageWithText:(NSString *)text {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *str = text;
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0f) options:0 attributes:DEFAULT_TEXT_ATTRIBUTES context:(__bridge NSStringDrawingContext *)(context)];
    CGSize size = CGSizeMake(textRect.size.width + TAG_TEXT_INSET * 2, TAG_HEIGHT);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:size.height/2];
    [[UIColor lightGrayColor] setFill];
    [bezierPath fill];
    
    [str drawAtPoint:CGPointMake(TAG_TEXT_INSET, 5) withAttributes:DEFAULT_TEXT_ATTRIBUTES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  set a tag's background image for selected/highlighted state
 *
 *  @param text tag's title
 *
 *  @return highlighted image
 */
- (UIImage *)setSelectedTagImageWithText:(NSString *)text {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *str = text;
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0.0f) options:0 attributes:DEFAULT_TEXT_ATTRIBUTES context:(__bridge NSStringDrawingContext *)(context)];
    CGSize size = CGSizeMake(textRect.size.width + TAG_TEXT_INSET * 2, TAG_HEIGHT);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:size.height/2];
    [[UIColor orangeColor] setFill];
    [bezierPath fill];
    
    [str drawAtPoint:CGPointMake(TAG_TEXT_INSET, 5) withAttributes:DEFAULT_TEXT_ATTRIBUTES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  check all the attributed string with a tag's id. if a tag with this id exists, return the tag's range, else return a empty range.
 */
- (NSRange) tagRangeForIdentifier:(NSString *)identifier {
    __block NSRange resultRange = NSMakeRange(0, 0);
    NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment) {
            TKTextAttachment *textAttachment = (TKTextAttachment *)attachment;
            if ([textAttachment.theId isEqualToString:identifier]) {
                resultRange = range;
                *stop = YES;
            }
        }
    }];
    return resultRange;
}

/**
 *  check a tag with it's ID, and return it's frame
 *  search a tag or select a tag would allocate this method
 *
 *  @param identifier ID
 *
 *  @return a tag's rect
 */
- (CGRect) frameOfTagForIdentifier:(NSString *)identifier {
    __block CGRect result = CGRectMake(0, 0, 0, 0);
    
    NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment) {
            TKTextAttachment *textAttachment = (TKTextAttachment *)attachment;
            if ([textAttachment.theId isEqualToString:identifier]) {
                result = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
                result.origin.x += self.textContainerInset.left;
                result.origin.y += self.textContainerInset.top;
                
                if (result.size.height > textAttachment.expectedSize.height) {
                    result.origin.y -= (result.size.height - textAttachment.expectedSize.height - LINE_SPACING);
                    result.size.height -= LINE_SPACING;
                }else {
                    result.origin.y += (result.size.height - textAttachment.expectedSize.height);
                    result.size.height -= (result.size.height - textAttachment.expectedSize.height);
                }
                *stop = YES;
            }
        }
    }];
    
    return result;
}
/**
 *  check wehter a tag with this ID exists. return YES if the tag exists.
 */
- (BOOL) attachmentExistsWithIdentifier:(NSString *)identifier {
    __block BOOL result = NO;
    
    NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment) {
            TKTextAttachment *textAttachment = (TKTextAttachment *)attachment;
            if ([textAttachment.theId isEqualToString:identifier]) {
                result = YES;
                *stop = YES;
            }
        }
    }];
    return result;
}
/**
 *  when we tap at screen, we wanna konw wether the point we tap is in a tag's frame. If taping a tag, returns a tag object, else return nil.
 *
 *  @param point tap point
 */
- (TKTextAttachment *) attachmentAtPoint:(CGPoint)point {
    NSTextContainer *textContainer = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;
    
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    if (characterIndex >= self.text.length)
        return nil;
    
    NSRange range;
    TKTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];
    // The NSLayoutManager characterIndexForPoint:inTextContainer:fractionOfDistanceBetweenInsertionPoints method returns the closest glyph but we want to only select one if it's actually under the point.
    CGRect boundingRect = [layoutManager boundingRectForGlyphRange:range inTextContainer:textContainer];
    if (CGRectContainsPoint(boundingRect, point))  return attachment;

    return nil;
}


// --------------------------------------------
#pragma mark - UITextViewDelegate & Methods -
// --------------------------------------------

- (void)textViewDidChange:(UITextView *)textView {
    [_highlightedTagView removeFromSuperview];
    [self calculateAll];
}

- (BOOL) shouldChangeTextInRange:(NSRange)editingRange replacementText:(NSString *)text {
   
    //__block BOOL result = YES;
    
    if (editingRange.location == 0 && editingRange.length == self.attributedText.string.length)
    {
        //NSLog(@"<<<<<< --- all cleared by keyboard");
        [self clearAll];
        return YES;
    }
    // inserting text in a tag
    if (text.length > 0) {
        if (_shouldDeleteTagRange.length > 0) {
            [_highlightedTagView removeFromSuperview];
            self.attributedText = [self attributedStringShouldReplaceRange:_shouldDeleteTagRange withTargetString:text];
            self.selectedRange = NSMakeRange(_shouldDeleteTagRange.location, 0);
            _shouldDeleteTagRange = NSMakeRange(0, 0);
            return NO;
        }
    }
    // Deleting
    else {
        //NSLog(@"deleting");
        if (editingRange.location == -1) {
            editingRange.location = 0;
            [self clearAll];
        }
        if (_shouldDeleteTagRange.length > 0) {
            [_highlightedTagView removeFromSuperview];
            self.attributedText = [self attributedStringShouldReplaceRange:_shouldDeleteTagRange withTargetString:text];
            self.selectedRange = NSMakeRange(_shouldDeleteTagRange.location-1, 0);
            _shouldDeleteTagRange = NSMakeRange(0, 0);
            return NO;
        }
        else {
            NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
            [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                if (attachment) {
                    //NSLog(@"%lu,%lu",range.location,range.length);
                    if (editingRange.location == range.location + range.length) {
                        //NSLog(@"editing in a tag");
                        _shouldDeleteTagRange = NSMakeRange(range.location, range.length);
                        
                        [_highlightedTagView removeFromSuperview];
                        self.attributedText = [self attributedStringShouldReplaceRange:_shouldDeleteTagRange withTargetString:text];
                        self.selectedRange = NSMakeRange(_shouldDeleteTagRange.location, 0);
                        _shouldDeleteTagRange = NSMakeRange(0, 0);
                    }
                }
            }];
        }
    }
    return YES;
}

- (void)clearAll {
    self.attributedText = _blank;
}
/**
 *  allocate this method will clear all tags and leaving attributed string as same as tags' title instead of them.
 */
- (void) clearAllTags {
    if (_highlightedTagView) {
        [_highlightedTagView removeFromSuperview];
    }
    
    for (int i = 0; i <= self.tagList.count +20; i++) {
        NSRange limitRange = NSMakeRange(0, [self.attributedText length]);
        __block NSRange shouldReplaceRange = NSMakeRange(0, 0);
        [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:limitRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(TKTextAttachment *attachment, NSRange range, BOOL *stop) {
            if (attachment && [attachment.type isEqualToString:@"location"]) {
                NSLog(@"tag:%@ --ranges:%lu,%lu",attachment.theName,range.location,range.length);
                NSString *targetStr = [NSString stringWithFormat:@" %@,",attachment.theName];
                self.attributedText = [self attributedStringShouldReplaceRange:range withTargetString:targetStr];
                shouldReplaceRange = range;
                *stop = YES;
            }
        }];
    }
}
/**
 *   Cut out string of range on full stringto get head + tail without middle
 *
 *  @param cuttingRange middle range will be cutted
 */
- (NSAttributedString *) attributedStringWithCutOutOfRange:(NSRange)cuttingRange
{
    // Cutting Heads
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:DEFAULT_TEXT_ATTRIBUTES];
    // Cutting Tail
    NSAttributedString *tail = nil;
    if (cuttingRange.location + cuttingRange.length <= self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(cuttingRange.location + cuttingRange.length, self.attributedText.length - cuttingRange.location - cuttingRange.length)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:DEFAULT_TEXT_ATTRIBUTES];
    if (head)
        [conts appendAttributedString:head];
    if (tail)
        [conts appendAttributedString:tail];
    
    return conts;
}
/**
 *  Replace the string of range with a tagrget string on full
 *
 *  @param cuttingRange would be replaced range
 *  @param targetString target string
 */
- (NSAttributedString *) attributedStringShouldReplaceRange:(NSRange)cuttingRange withTargetString:(NSString *)targetString
{
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:DEFAULT_TEXT_ATTRIBUTES];
    // Cutting Tail
    NSAttributedString *tail = nil;
    if (cuttingRange.location + cuttingRange.length <= self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(cuttingRange.location + cuttingRange.length, self.attributedText.length - cuttingRange.location - cuttingRange.length)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:targetString attributes:DEFAULT_TEXT_ATTRIBUTES];
    if (head)
        [conts insertAttributedString:head atIndex:0];
    if (tail)
        [conts appendAttributedString:tail];
    
    return conts;
}


// --------------------------------------------
#pragma mark - UIGestureRecognizerDelegate -
// --------------------------------------------

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // If we're touching an attachment then we don't want the normal selection functionality to be done
    // Let's make some animations!
    CGPoint point = [recognizer locationInView:self];
    TKTextAttachment *attachment = [self attachmentAtPoint:point];
    if (attachment) {
        NSLog(@"selected tag Name: %@",attachment.theName);
        CGRect frame = [self frameOfTagForIdentifier:attachment.theId];
        if (_highlightedTagView) {
            [_highlightedTagView removeFromSuperview];
        }
        _highlightedTagView = [[UIImageView alloc] initWithFrame:frame];
        [_highlightedTagView setImage:[self setSelectedTagImageWithText:attachment.theName]];
        [self addSubview:_highlightedTagView];

        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.duration = 0.1;
        scaleAnimation.repeatCount = 100000;
        scaleAnimation.autoreverses = NO;
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(_highlightedTagView.layer.transform, -0.03, 0.0, 0.0, 0.03)];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(_highlightedTagView.layer.transform, 0.03, 0.0, 0.0, 0.03)];
        [_highlightedTagView.layer addAnimation:scaleAnimation forKey:@"wiggle"];
        
        NSRange range = [self tagRangeForIdentifier:attachment.theId];
        _shouldDeleteTagRange = NSMakeRange(range.location ,range.length + 1);
        self.selectedRange = NSMakeRange(range.location, 0);
        NSLog(@"selected tag's range is :(%lu,%lu)",range.location,range.length);
    }else {
        [_highlightedTagView removeFromSuperview];
        _shouldDeleteTagRange = NSMakeRange(0, 0);
    }
    return YES;
}
// MARK: PreformAction
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

@end
