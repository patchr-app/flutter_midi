#import "MidiPlugin.h"
#import <midi/midi-Swift.h>

@implementation MidiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMidiPlugin registerWithRegistrar:registrar];
}
@end
