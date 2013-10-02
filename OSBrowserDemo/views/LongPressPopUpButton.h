//
//  LongPressPopUpButton.h
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-1.
//
//

#import "LongPressButton.h"

@class LongPressPopUpButton;

@protocol LongPressPopUpButtonDataSource

- (NSMenu *)popupMenuForLongPressAction:(LongPressPopUpButton *)button;

@end

@interface LongPressPopUpButton : LongPressButton

@property (nonatomic, assign) id<LongPressPopUpButtonDataSource> dataSource;

@end
