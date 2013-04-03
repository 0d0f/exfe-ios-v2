//
//  EXCardCell.m
//  EXFE
//
//  Created by 0day on 13-4-1.
//
//

#import "EXCardCell.h"

#import "Identity+EXFE.h"
#import "Util.h"

@interface EXCardCell ()
- (void)privacyStateChanged;
@end

@implementation EXCardCell

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXCardCell"
                                           owner:nil
                                         options:nil] lastObject] retain];
    return self;
}

- (void)dealloc {
    [_displayIdentityLabel release];
    [_providerLabel release];
    [_pravicyLabel release];
    [super dealloc];
}

- (void)setIdentity:(Identity *)identity {
    if (identity == _identity)
        return;
    if (_identity) {
        _identity = nil;
        self.displayIdentityLabel.text = @"";
        self.pravicyLabel.text = @"";
        self.providerLabel.text = @"";
    }
    if (identity) {
        _identity = identity;
        self.displayIdentityLabel.text = [identity getDisplayIdentity];
        self.providerLabel.text = [identity.provider capitalizedString];
        
#warning test only 需要确认这里的接口
        self.pravicyLabel.text = @"Public";
    }
}

- (void)setPravicyState:(EXCardCellPravicyState)pravicyState {
    if (pravicyState == _pravicyState || !self.identity)
        return;
    _pravicyState = pravicyState;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self privacyStateChanged];
    });
}

- (void)privacyStateChanged {
    UIColor *color = nil;
    if (kEXCardCellPravicyStatePublic == self.pravicyState) {
        color = [UIColor whiteColor];
        self.pravicyLabel.text = @"Public";
    } else {
        color = [UIColor COLOR_RGB(0x7F, 0x7F, 0x7F)];
        self.pravicyLabel.text = @"Private";
    }
    
    self.providerLabel.textColor = color;
    self.displayIdentityLabel.textColor = color;
    self.pravicyLabel.textColor = color;
}

@end
