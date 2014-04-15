#import "Mixpanel.h"
#import "ComponentUtil.h"
#import "MyToolTip.h"

#define SERVERURL @"http://www.dennyzhang.com:9180/"
//#define SERVERURL @"http://50.198.76.252:9180/"

#define APP_NAME @"CoderQuiz"
#define MORE_CATEGORY @"Manage Subscription"
#define APP_SETTING @"App Setting"
#define SAVED_QUESTIONS @"Saved Questions"
#define NONE_QUESTION_CATEGORY @"NONE_QUESTION_CATEGORY"

#define FONT_BIG 22
#define FONT_NORMAL 17
#define FONT_SIZE_TITLE 18
#define FONT_SMALL 13
#define FONT_TINY 10
#define FONT_TINY2 8

#define FONT_NAME1 @"ArialMT"

#define FONT_NAME_TITLE @"Helvetica Light"
//BradleyHandITCTT-Bold

#define FONT_NAME_CONTENT @"Helvetica Light"

#define ICON_WIDTH 28.0f
#define ICON_HEIGHT 28.0f

#define ICON_WIDTH_SMALL 23.0f
#define ICON_HEIGHT_SMALL 23.0f

#define ICON_CHWIDTH 9.0f
#define ICON_CHHEIGHT 21.0f

#define ICON_WIDTH2 35.0f
#define ICON_HEIGHT2 35.0f

#define HIDE_MESSAGEBOX_DELAY 1.0f

#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithRed:246.0f/255.0f green:244.0f/255.0f blue:231.0f/255.0f alpha:1.0f]

#define MAX_SECONDS_FOR_VALID_STAY 120
#define MIXPANEL_TOKEN @"788d5bfa071188e96a45a2ae30bbbebe"
