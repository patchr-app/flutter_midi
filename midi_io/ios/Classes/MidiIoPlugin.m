#import "MidiIoPlugin.h"
#if __has_include(<midi_io/midi_io-Swift.h>)
#import <midi_io/midi_io-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "midi_io-Swift.h"
#endif

@implementation MidiIoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMidiIoPlugin registerWithRegistrar:registrar];
}
@end
