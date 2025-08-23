import React, { useEffect, useState } from 'react';
import {
  View,
  TouchableOpacity,
  ScrollView,
  DeviceEventEmitter,
} from 'react-native';
import { Text } from './ui/text';
import { TurnkeyConfigs } from '../sharedConfigs';
import { useAuthRelay } from '../hooks/useAuthRelay';
import { OAuthInput } from './OAuthInput';
import { EmailInput } from './EmailInput';
import { useThemedStyles } from '../turnkeyStyle';
import { LoginMethod } from '../lib/types';
import { DydxAddressReceivedEvent, EmailTokenReceivedEvent, TurnkeyNativeModule } from '../../TurnkeyModule';
import { useEmbeddedKeyAndNonce } from './useEmbeddedKeyAndNonce';
import { Image } from 'react-native';
import { currentTheme } from '../../rn_style/themes/currentTheme';
import { DydxTurnkeySession } from '../providers/dydxTurnkeySession';


const renderError = () => {
  const {
    state,
  } = useAuthRelay();

  if (state.error && state.loading === null) {
    return (
      <Text style={{ color: currentTheme.colors.red, marginBottom: 20, textAlign: 'center' }}>
        {state.error}
      </Text>
    );
  }
  return null;
}

export const Auth = ({ configs }: { configs: TurnkeyConfigs }) => {
  const {
    loginWithOAuth,
    uploadDydxAddress,
    completeOtpAuth,
  } = useAuthRelay();

  const [session, setSession] = useState<DydxTurnkeySession | undefined>(undefined);

  const oAuthEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.OAuth);
  const emailEmbeddedKeyAndNonce = useEmbeddedKeyAndNonce(LoginMethod.Email);

  useEffect(() => {
    DeviceEventEmitter.removeAllListeners('DydxAddressReceived');
    DeviceEventEmitter.addListener(
      'DydxAddressReceived',
      async ({ callbackId, dydxAddress }: DydxAddressReceivedEvent) => {
        if (!session) {
          console.error("No DYDX session available");
          TurnkeyNativeModule.onJsResponse(callbackId, "failed: No DYDX session available");
          return;
        }

        try {
          await uploadDydxAddress({
            dydxSession: session,
            dydxAddress: dydxAddress,
            configs: configs,
          })
          TurnkeyNativeModule.onJsResponse(callbackId, "success");
        } catch (error) {
          console.error("Error uploading dydx address:", error);
          TurnkeyNativeModule.onJsResponse(callbackId, "failed: " + error);
        }
      }
    );
  });

  useEffect(() => {
    DeviceEventEmitter.removeAllListeners('EmailTokenReceived');
    DeviceEventEmitter.addListener(
      'EmailTokenReceived',
      async ({ token }: EmailTokenReceivedEvent) => {
        const session = await completeOtpAuth({
          otpType: "email",
          token: token,
          configs: configs,
        });

        setSession(session);

        await emailEmbeddedKeyAndNonce.refreshNonce();
      }
    );
  }, [emailEmbeddedKeyAndNonce]);

  const styles = useThemedStyles(currentTheme);

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
          <Text style={styles.title}>{configs.strings["APP.TURNKEY_ONBOARD.SIGN_IN_TITLE"]}</Text>
          <Text style={styles.subtitle}>
            {configs.strings["APP.TURNKEY_ONBOARD.SIGN_IN_DESCRIPTION"]}
          </Text>

          {/* Social icons row */}
          <View style={styles.socialRow}>
            <OAuthInput
              onSuccess={async (params) => {
                const session = await loginWithOAuth(params);
                setSession(session);
              }}
              configs={configs}
              embeddedKeyAndNonce={oAuthEmbeddedKeyAndNonce} />
          </View>

          {/* Email input row */}
          <View style={styles.emailRow}>
            <EmailInput
              embeddedKeyAndNonce={emailEmbeddedKeyAndNonce}
              configs={configs}
            />
          </View>

          {renderError()}

        </View>

        <View>

          {/* Divider */}
          <View style={styles.dividerContainer}>
            <View style={styles.divider} />
            <Text style={styles.dividerText}>{configs.strings["APP.GENERAL.OR"]}</Text>
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
            <Image
              source={require('../../rn_style/assets/icon_desktop.png')}
              style={{ width: 18, height: 18, marginEnd: 8, tintColor: currentTheme.colors.textSecondary }}
            />
            <Text style={styles.actionButtonText}>{configs.strings["APP.TURNKEY_ONBOARD.SIGN_IN_DESKTOP"]}</Text>
            <Image
              source={require('../../rn_style/assets/chevron_right.png')}
              style={{ height: 10, tintColor: currentTheme.colors.textTertiary }}
              resizeMode="contain"
            />
          </TouchableOpacity>

          {/* Sign in with Wallet */}
          <TouchableOpacity
            style={styles.actionButton}
            onPress={async () => {
              TurnkeyNativeModule.onAuthRouteToWallet();
            }}>
            <Image
              source={require('../../rn_style/assets/icon_wallet.png')}
              style={{ width: 16, height: 16, marginEnd: 8, tintColor: currentTheme.colors.textSecondary }}
            />
            <Text style={styles.actionButtonText}>{configs.strings["APP.TURNKEY_ONBOARD.SIGN_IN_WALLET"]}</Text>
            <Image
              source={require('../../rn_style/assets/chevron_right.png')}
              style={{ height: 10, tintColor: currentTheme.colors.textTertiary }}
              resizeMode="contain"
            />
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}
