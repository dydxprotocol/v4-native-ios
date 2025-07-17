import {AppRegistry, NativeModules, DeviceEventEmitter} from 'react-native';
import App from './App';
import {TurnkeyLogin} from './TurnkeyReact/TurnkeyLogin';

AppRegistry.registerComponent('TurnkeyReact', () => App);
AppRegistry.registerComponent('TurnkeyLogin', () => TurnkeyLogin);