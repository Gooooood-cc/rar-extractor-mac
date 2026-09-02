#import <Cocoa/Cocoa.h>

static NSString * const ExtractorErrorDomain = @"local.codex.ExtractRAR";

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, assign) BOOL handledOpenEvent;
- (NSURL *)extractRARAtPath:(NSString *)path error:(NSError **)error;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.handledOpenEvent) {
            return;
        }
        [self showAlertWithTitle:@"解压 RAR"
                         message:@"请把 .rar 文件拖到这个 App 上，或把它设为 .rar 的默认打开方式后双击压缩包。"];
        [NSApp terminate:nil];
    });
}

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    self.handledOpenEvent = YES;
    BOOL ok = [self extractFilesAtPaths:filenames];
    [sender replyToOpenOrPrint:ok ? NSApplicationDelegateReplySuccess : NSApplicationDelegateReplyFailure];
    [NSApp terminate:nil];
}

- (BOOL)extractFilesAtPaths:(NSArray<NSString *> *)paths {
    NSMutableArray<NSURL *> *destinations = [NSMutableArray array];
    NSMutableArray<NSString *> *errors = [NSMutableArray array];

    for (NSString *path in paths) {
        NSError *error = nil;
        NSURL *destination = [self extractRARAtPath:path error:&error];
        if (destination) {
            [destinations addObject:destination];
        } else {
            NSString *name = path.lastPathComponent ?: path;
            [errors addObject:[NSString stringWithFormat:@"%@: %@", name, error.localizedDescription ?: @"未知错误"]];
        }
    }

    if (destinations.count > 0) {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:destinations];
    }

    if (errors.count > 0) {
        [self showAlertWithTitle:@"有文件没有解压成功" message:[errors componentsJoinedByString:@"\n\n"]];
    }

    return errors.count == 0;
}

- (NSURL *)extractRARAtPath:(NSString *)path error:(NSError **)error {
    NSURL *inputURL = [NSURL fileURLWithPath:path];
    if (![inputURL.pathExtension.lowercaseString isEqualToString:@"rar"]) {
        if (error) {
            *error = [NSError errorWithDomain:ExtractorErrorDomain
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: @"只支持 .rar 文件"}];
        }
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *parentURL = [inputURL URLByDeletingLastPathComponent];
    NSString *baseName = [[inputURL URLByDeletingPathExtension] lastPathComponent];
    NSURL *destinationURL = [parentURL URLByAppendingPathComponent:baseName isDirectory:YES];
    NSInteger suffix = 2;

    while ([fileManager fileExistsAtPath:destinationURL.path]) {
        destinationURL = [parentURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %ld", baseName, (long)suffix]
                                                    isDirectory:YES];
        suffix += 1;
    }

    if (![fileManager createDirectoryAtURL:destinationURL withIntermediateDirectories:YES attributes:nil error:error]) {
        return nil;
    }

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/bsdtar";
    task.arguments = @[@"-xf", inputURL.path, @"-C", destinationURL.path];

    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    task.standardError = pipe;

    @try {
        [task launch];
        [task waitUntilExit];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:ExtractorErrorDomain
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"无法启动 bsdtar"}];
        }
        return nil;
    }

    if (task.terminationStatus != 0) {
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (message.length == 0) {
            message = @"bsdtar 解压失败";
        }
        if (error) {
            *error = [NSError errorWithDomain:ExtractorErrorDomain
                                         code:3
                                     userInfo:@{NSLocalizedDescriptionKey: message}];
        }
        return nil;
    }

    return destinationURL;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"好"];
    [alert runModal];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc > 1 && strncmp(argv[1], "-psn_", 5) != 0) {
            AppDelegate *extractor = [[AppDelegate alloc] init];
            BOOL ok = YES;

            for (int index = 1; index < argc; index += 1) {
                NSString *path = [NSString stringWithUTF8String:argv[index]];
                NSError *error = nil;
                NSURL *destination = [extractor extractRARAtPath:path error:&error];
                if (destination) {
                    printf("%s\n", destination.path.UTF8String);
                } else {
                    ok = NO;
                    fprintf(stderr, "%s: %s\n", argv[index], error.localizedDescription.UTF8String ?: "unknown error");
                }
            }

            return ok ? 0 : 1;
        }

        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}

