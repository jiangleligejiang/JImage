//
//  JImage.h
//  JImage
//
//  Created by jams on 2019/4/18.
//  Copyright © 2019 jams. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef JImage_h
#define JImage_h

#ifndef safe_dispatch_queue_async
#define safe_dispatch_queue_async(queue, block) \
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {\
        block();\
    } else {\
    dispatch_async(queue, block);\
    }
#endif

#ifndef safe_dispatch_main_async
#define safe_dispatch_main_async(block)  safe_dispatch_queue_async(dispatch_get_main_queue(), block)
#endif


#endif /* JImage_h */
