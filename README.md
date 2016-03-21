# Objective-JNI-Environment
Objective-JNI Environment for generated classes by Objective-JNI Generator

## Usage
1. Initialize Java VM in app startup moment, for example in AppDelegate's didFinishLaunchingWithOptions
```
[[OJNIJavaVM sharedVM] initializeJVM];
// Also you can specify your own options
[[OJNIJavaVM sharedVM] initializeJVMWithArgs:@[@"-rvm:log=trace"]];
```
2. Operate your logic as usual.


# Objective-JNI Generator
For more information visit https://github.com/ashitikov/Objective-JNI
