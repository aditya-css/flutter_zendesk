#import "ZendeskSupportPlugin.h"
#if __has_include(<zendesk_support/zendesk_support-Swift.h>)
#import <zendesk_support/zendesk_support-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zendesk_support-Swift.h"
#endif

@implementation ZendeskSupportPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZendeskSupportPlugin registerWithRegistrar:registrar];
}
@end
