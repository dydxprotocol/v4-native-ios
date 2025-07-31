import {AppRegistry} from 'react-native';
import App from './App';
import 'react-native-get-random-values';
import {TurnkeyLogin} from './TurnkeyReact/TurnkeyLogin';
import 'react-native-url-polyfill/auto';

AppRegistry.registerComponent('TurnkeyReact', () => App);
AppRegistry.registerComponent('TurnkeyLogin', () => TurnkeyLogin);