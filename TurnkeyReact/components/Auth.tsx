import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { TurnkeyConfigs } from '../sharedConfigs';
import { useAuthRelay } from '../hooks/useAuthRelay';
import { OAuthInput } from './OAuthInput';
import { EmailInput } from './EmailInput';
import { styles } from "../turnkeyStyle";
import { LoaderButton } from './ui/button';
import { LoginMethod, OtpType } from '../lib/types';
import { TurnkeyNativeModule } from '../../TurnkeyModule';
import { useEmbeddedKeyAndNonce } from './useEmbeddedKeyAndNonce';

const renderError = () => {
  const {
    state,
  } = useAuthRelay();

  if (state.error && state.loading === null) {
    return (
      <Text style={{ color: 'red', marginBottom: 20, textAlign: 'center' }}>
        {state.error}
      </Text>
    );
  }
  return null;
}

export const Auth = ({ configs }: { configs: TurnkeyConfigs }) => {
  const {
    state,
    initOtpLogin,
    signUpWithPasskey,
    loginWithPasskey,
    loginWithOAuth,
    clearError
  } = useAuthRelay();

  const [email, setEmail] = useState<string>('');
  const [isValidEmail, setIsValidEmail] = useState<boolean>(false);

  const oAuthEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.OAuth);
  const emailEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.Email);


  return (
    <ScrollView
      bounces={false} // iOS
      overScrollMode="never" // Android
      contentContainerStyle={styles.container}
    >
      <View style={styles.content}>
        <View>
          {/* Draggable indicator bar */}
          <View style={styles.dragHandle} />

          {/* Header */}
          <Text style={styles.title}>Sign in</Text>
          <Text style={styles.subtitle}>
            To get started, sign in with your social accounts, create a passkey or
            connect your wallet.
          </Text>

          {/* Social icons row */}
          <View style={styles.socialRow}>
            <OAuthInput
              onSuccess={loginWithOAuth}
              configs={configs}
              embeddedKeyAndNonce={oAuthEmbeddedKeyAndNonce} />
          </View>

          {/* Email input row */}
          <View style={styles.emailRow}>
            <EmailInput
              initialValue={email}
              onEmailChange={setEmail}
              onValidationChange={setIsValidEmail}
              embeddedKeyAndNonce={emailEmbeddedKeyAndNonce}
              configs={configs}
            />
            <LoaderButton
              variant="outline"
              disabled={!!state.loading || !isValidEmail}
              loading={state.loading === LoginMethod.Email}
              onPress={() =>
                initOtpLogin({
                  otpType: OtpType.Email,
                  contact: email,
                  embeddedKeyAndNonce: emailEmbeddedKeyAndNonce,
                  configs: configs,
                })
              }
            >
              <Text style={styles.submitButtonText}>Submit</Text>
            </LoaderButton>
          </View>

          {renderError()}

        </View>

        <View>

          {/* Divider */}
          <View style={styles.dividerContainer}>
            <View style={styles.divider} />
            <Text style={styles.dividerText}>Or</Text>
            <View style={styles.divider} />
          </View>

          {/* Sign in with Passkey */}
          {/* <TouchableOpacity style={styles.actionButton}>
          <Ionicons
            name="person"
            size={18}
            color="#fff"
            style={{ marginRight: 8 }}
          />
          <Text style={styles.actionButtonText}>Sign in with Passkey</Text>
        </TouchableOpacity> */}

          {/* Sign in with Desktop */}
          <TouchableOpacity
            style={styles.actionButton}
            onPress={async () => {
              TurnkeyNativeModule.onAuthRouteToDesktopQR();
            }}>
            <Ionicons
              name="person"
              size={18}
              color="#fff"
              style={{ marginRight: 8 }}
            />
            <Text style={styles.actionButtonText}>Sign in with Desktop</Text>
          </TouchableOpacity>

          {/* Sign in with Wallet */}
          <TouchableOpacity
            style={styles.actionButton}
            onPress={async () => {
              TurnkeyNativeModule.onAuthRouteToWallet();
            }}>
            <Ionicons
              name="wallet"
              size={18}
              color="#fff"
              style={{ marginRight: 8 }}
            />
            <Text style={styles.actionButtonText}>Sign in with Wallet</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}
