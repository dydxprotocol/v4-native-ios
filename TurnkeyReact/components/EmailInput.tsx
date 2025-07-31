import * as React from "react";
import { Input } from "../components/ui/input";
import { useThemedStyles } from '../turnkeyStyle';
import { DeviceEventEmitter, Image, View } from "react-native";
import { Text } from './ui/text';
import { EmailTokenReceivedEvent } from "../../TurnkeyModule";
import { useEffect, useState } from 'react';
import { useAuthRelay } from "../hooks/useAuthRelay";
import { TurnkeyConfigs } from "../sharedConfigs";
import { EmbeddedKeyAndNonce } from "./useEmbeddedKeyAndNonce";
import { Button } from "./ui/button";
import { OtpType } from "../lib/types";
import { currentTheme } from "../../rn_style/themes/currentTheme";

interface EmailInputProps {
  embeddedKeyAndNonce: EmbeddedKeyAndNonce;
  configs: TurnkeyConfigs;
}

export const EmailInput = ({
  embeddedKeyAndNonce,
  configs,
}: EmailInputProps) => {
  const { initOtpLogin, completeOtpAuth, state } = useAuthRelay();
  const [email, setEmail] = useState<string>('');
  const [isValidEmail, setIsValidEmail] = useState<boolean>(false);

  const styles = useThemedStyles(currentTheme);

  useEffect(() => {
    DeviceEventEmitter.removeAllListeners('EmailTokenReceived');
    DeviceEventEmitter.addListener(
      'EmailTokenReceived',
      async ({ token }: EmailTokenReceivedEvent) => {
        console.log("Email token Received:", token);
        completeOtpAuth({
          otpType: "email",
          token: token,
          embeddedKeyAndNonce: embeddedKeyAndNonce,
          configs: configs,
        });

        await embeddedKeyAndNonce.refreshNonce();
      }
    );
  }, [embeddedKeyAndNonce]);

  return (
    <View style={{ flex: 1, flexDirection: "row", alignItems: "center", justifyContent: "center" }}>
      <Image
        source={require('../../rn_style/assets/logo_mail.png')}
        style={{ width: 24, height: 24, tintColor: currentTheme.colors.textTertiary }}
      />

      <Input
        style={styles.emailInput}
        autoCapitalize="none"
        autoComplete="email"
        autoCorrect={false}
        keyboardType="email-address"
        placeholderTextColor="#888"
        placeholder="Enter your email"
        value={email}
        onChangeText={(text: string) => {
          setEmail(text);
          const isValid = validateEmail(text);
          setIsValidEmail(isValid);
        }}
        aria-labelledby="emailLabel"
        aria-errormessage="emai`lError"
      />

      <Button
        disabled={!!state.loading || !isValidEmail}
        onPress={() =>
          initOtpLogin({
            otpType: OtpType.Email,
            contact: email,
            embeddedKeyAndNonce: embeddedKeyAndNonce,
            configs: configs,
          })
        }
      >
        <Text style={styles.submitButtonText}>Submit</Text>
      </Button>
    </View>



  );
};

const validateEmail = (email: string | undefined) => {
  if (!email) return false;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
