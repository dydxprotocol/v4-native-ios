import {AppRegistry, NativeModules, DeviceEventEmitter} from 'react-native';
import App from './App';
import 'react-native-get-random-values'
import {TurnkeyLogin} from './TurnkeyReact/TurnkeyLogin';

AppRegistry.registerComponent('TurnkeyReact', () => App);
AppRegistry.registerComponent('TurnkeyLogin', () => TurnkeyLogin);