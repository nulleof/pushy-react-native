import { Platform, AppRegistry, NativeModules, NativeEventEmitter } from 'react-native';

// Expose all native PushyModule methods
const Pushy = Platform.OS === 'android' ? NativeModules.PushyModule : NativeModules.RNPushyModule;

// Pushy module not loaded?
if (!Pushy) {
    // Are we running on an Android device?
    if (Platform.OS === 'android') {
        // Log fatal error
        console.error('Pushy native module not loaded, please include the PushyPackage() declaration within your app\'s MainApplication.getPackages() implementation.');
    }
}
else {
    // Expose custom notification listener
    if (Platform.OS === 'android') {
      Pushy.setNotificationListener = (handler) => {
        // Listen for push notifications via Headless JS task
        AppRegistry.registerHeadlessTask('PushyPushReceiver', () => {
          // React Native will execute the handler via Headless JS when the task is called natively
          return handler;
        });
      };
    } else { // IOS
      const pushyEventEmitter = new NativeEventEmitter(Pushy);

      Pushy.setNotificationListener = (handler) => {
        // Listen for push notifications via Headless JS task
        pushyEventEmitter.addListener('NotificationReceived', handler);
      };

      Pushy.notify = () => {
          // console.log('Is not implemented');
      }

      Pushy.listen = () => {
          // console.log('Is not implemented');
      }
    }
}

// Expose module
export default Pushy;
