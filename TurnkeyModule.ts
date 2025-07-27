
import { NativeModules } from 'react-native';

// Define type for native module
interface TurnkeyNativeModuleType {
  onJsResponse: (callbackId: string, result: string) => void;

  onAuthRouteToWallet: () => void;
  onAuthRouteToDesktopQR: () => void;
  onAuthCompleted: (onboardingSignature: string, evmAddress: string, svmAddress: string) => void;

  onAppleAuthRequest: (nonce: string) => void;
}

// Safely cast NativeModules
export const { TurnkeyNativeModule } = NativeModules as {
  TurnkeyNativeModule: TurnkeyNativeModuleType;
};

// Define type for event payload
export interface NativeToJsRequestEvent {
  callbackId: string;
}

// Define type for event payload
export interface AppleSignInCompletedEvent {
  identityToken: string | null;
  error: string | null;
}

