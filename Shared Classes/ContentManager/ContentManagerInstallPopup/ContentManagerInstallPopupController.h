//
//  ContentManagerInstallPopup.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 12.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentManager.h"
#import "ProgressBar.h"
@import UIKit;


@interface ContentManagerInstallPopupController : UIViewController <ContentManagerObserver> {
    
    UIVisualEffectView* _effectView;
    UIView* _blendView;
    
    float _progress;
    
    BOOL _downloadFinished;
}

@property (nonatomic, strong) NSString* courseTitle;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) IBOutlet UIView* step1View;

@property (nonatomic, strong) IBOutlet UIView* step2View;

@property (nonatomic, strong) IBOutlet UIView* step3View;
@property (strong, nonatomic) IBOutlet UILabel *step1Label;

@property (strong, nonatomic) IBOutlet UILabel *step2Label;

@property (strong, nonatomic) IBOutlet UILabel *step2ProgressLabel;

@property (strong, nonatomic) IBOutlet ProgressBar *step2ProgressBar;

@property (strong, nonatomic) IBOutlet UIButton *step2CancelButton;

@property (strong, nonatomic) IBOutlet UILabel *step3Label;

@property (nonatomic, strong) void(^cancelCloseBlock)();

@property (nonatomic, strong) void(^cancelDownloadBlock)();

@property (nonatomic, strong) void(^confirmDownloadBlock)();

@property (nonatomic, strong) void(^confirmDownloadCompleteBlock)();


- (IBAction)actionCancelClose:(id)sender;
- (IBAction)actionConfirmDownload:(id)sender;

- (IBAction)actionCancelDownload:(id)sender;
- (IBAction)actionConfirmClose:(id)sender;
@end
