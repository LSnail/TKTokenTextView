//
//  TTokenTextViewController.m
//  New Momento
//
//  Created by 韩驰 on 15/9/25.
//  Copyright (c) 2015年 Toki. All rights reserved.
//

#import "TTokenTextViewController.h"
#import "TKTextStorage.h"
#import "TKTextAttachment.h"
#import "TokenTextView.h"

#import "Names.h"
#import "Locations.h"

#define DEFAULT_TEXT_ATTRIBUTES [self setDefaultAttributes]

#define DEFAULT_TITLE_HEIGTH                    60.0f
#define DEFAULT_TITLEVIEW_HEIGHT                42.0
#define DEFAULT_MAX_HEIGHT                      90.0
#define TAG_TEXT_INSET                          10.0f
#define TAG_HEIGHT                              33.0f


typedef enum{
    SEARCH_NONE = 0,
    SEARCH_TITLE = 1,
    SEARCH_FRIEND,
    SEARCH_LOCATION
}SEARCH_TYPE;

@interface TTokenTextViewController () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>

{
    TKTextStorage                               *textStorage;
    NSLayoutManager                             *layoutManager;
    SEARCH_TYPE                                 searchFlag;
    
    
    float                                       textHeight;/**< textView's height */
}

@property (nonatomic,strong) TokenTextView      *tokenTextView;
@property (nonatomic,strong) UITableView        *resultTableView;

@property (nonatomic,strong) NSAttributedString *blank;
@property (nonatomic,strong) NSMutableArray     *locTagsArray;/**< current all locTags */
@property (nonatomic,strong) NSMutableArray     *invTagsArray;/**< current all invTags */

@property (nonatomic,strong) NSMutableArray     *inviteesArray;
@property (nonatomic,strong) NSMutableArray     *locationsArray;

@property (nonatomic,assign) int idCount;
@end

@implementation TTokenTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _blank = [[NSAttributedString alloc] initWithString:@" " attributes:DEFAULT_TEXT_ATTRIBUTES];
    
    [self setUpTokenTextView];
    [self setUpResultTableView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    searchFlag = SEARCH_LOCATION;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 80, 40)];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button setTitle:@"done" forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void) clickButton {
    [_tokenTextView clearAllTags];
}

// --------------------------------------------
#pragma mark - setUps -
// --------------------------------------------

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



- (void) setUpTokenTextView {
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"enter title, people and places" attributes:DEFAULT_TEXT_ATTRIBUTES];
    // parts of TextView
    textStorage = [[TKTextStorage alloc] init];
    [textStorage setAttributedString:attributedString];
    layoutManager = [[NSLayoutManager alloc] init];
    CGRect textVeiwRect = CGRectMake(0, 64, self.view.bounds.size.width, DEFAULT_TITLE_HEIGTH);
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textVeiwRect.size.width, CGFLOAT_MAX)];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    _tokenTextView = [[TokenTextView alloc] initWithFrame:textVeiwRect textContainer:textContainer];
    //_tokenTextView.font = [UIFont systemFontOfSize:40];
    _tokenTextView.typingAttributes = DEFAULT_TEXT_ATTRIBUTES;
    _tokenTextView.selectedRange = NSMakeRange(0, 0);
    [_tokenTextView setBackgroundColor:[UIColor brownColor]];
    
    // delegate
    _tokenTextView.delegate = self;
    
        [self.view addSubview:_tokenTextView];
}

- (void) tapATag {
    
}

- (void) setUpResultTableView {
    
    _resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + DEFAULT_TITLE_HEIGTH + 1, self.view.bounds.size.width, self.view.bounds.size.height - 64 - DEFAULT_TITLE_HEIGTH)];
    _resultTableView.backgroundColor = [UIColor whiteColor];
    
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;
    
    self.inviteesArray = [[Names listOfNames] copy];
    self.locationsArray = [[Locations listOfLocations] copy];
    
    [self.view addSubview:_resultTableView];
}

// --------------------------------------------
#pragma mark - TextView Delegate -
// --------------------------------------------

- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [_tokenTextView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    [_tokenTextView textViewDidChange:textView];

    // change textView's height
    if(_tokenTextView.contentSize.height > DEFAULT_TITLEVIEW_HEIGHT){
        if(_tokenTextView.contentSize.height > DEFAULT_MAX_HEIGHT)
            textHeight = DEFAULT_MAX_HEIGHT;
        else
            textHeight = _tokenTextView.contentSize.height + 10;
    }else{
        textHeight = DEFAULT_TITLEVIEW_HEIGHT;
    }
    
    
    // change search state
    if (textStorage.searchStatus == SEARCH_WITH_NAMES) {
        searchFlag = SEARCH_FRIEND;
        [_resultTableView reloadData];
    }
    else if (textStorage.searchStatus == SEARCH_AT_LOCATIONS) {
        searchFlag = SEARCH_LOCATION;
        [_resultTableView reloadData];
    }
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [_tokenTextView clearAllTags];
        [_tokenTextView resignFirstResponder];
        return NO;
    }
    
    return [_tokenTextView shouldChangeTextInRange:range replacementText:text];
}

// --------------------------------------------
#pragma mark - TableView Delegate & DataSource -
// --------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    if (searchFlag == SEARCH_FRIEND) {
        return self.inviteesArray.count;
    }else if (searchFlag == SEARCH_LOCATION) {
        return self.locationsArray.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(searchFlag == SEARCH_LOCATION){
        static NSString *cellIdentiferLOC = @"locationSelectCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentiferLOC];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentiferLOC];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = self.locationsArray[indexPath.row];
        return cell;
    }else if(searchFlag == SEARCH_FRIEND){
        static NSString *cellIdentiferINV = @"friendSelectCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentiferINV];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentiferINV];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = self.inviteesArray[indexPath.row];
        return cell;
    }else {
        return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tokenTextView becomeFirstResponder];
    
    NSString *selectedText = [NSString new];
    if (searchFlag == SEARCH_LOCATION) {
        selectedText = self.locationsArray[indexPath.row];
    }
    
    [_tokenTextView addTagWithString:selectedText andId:[NSString stringWithFormat:@"%d",_idCount++] andType:@"location"];

    [_tokenTextView setNeedsDisplay];
    
    
}



// --------------------------------------------
#pragma mark - Tag Methods -
// --------------------------------------------




// --------------------------------------------
#pragma mark - Layout -
// --------------------------------------------




#pragma mark - Keyboard show or hide Notification
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - Keyboard status

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    CGFloat newInset;
    if ([notification.name isEqualToString: UIKeyboardWillShowNotification])
        newInset = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    else
        newInset = 20;
    // 从这里来改变textView或者搜索结果tableView的bottom约束
    
}




@end
