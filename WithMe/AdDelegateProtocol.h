//
//  AdDelegateProtocol.h
//  WithMe
//
//  Created by 한정욱 on 2016. 8. 16..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#ifndef AdDelegateProtocol_h
#define AdDelegateProtocol_h

@protocol AdDelegate <NSObject>
@optional
- (void) viewUserProfile:(User*)user;
- (void) viewAdDetail:(Ad*)ad;
@end

#endif /* AdDelegateProtocol_h */
