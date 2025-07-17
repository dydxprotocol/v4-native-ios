import {AppRegistry, NativeModules, DeviceEventEmitter} from 'react-native';
import App from './App';
import {TurnkeyLogin} from './TurnkeyReact/TurnkeyLogin';
import 'react-native-get-random-values';

AppRegistry.registerComponent('TurnkeyReact', () => App);
AppRegistry.registerComponent('TurnkeyLogin', () => TurnkeyLogin);