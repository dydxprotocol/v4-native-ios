import * as React from "react";
import { Input } from "../components/ui/input";
import { styles } from "../turnkeyStyle";
import { DeviceEventEmitter } from "react-native";
import { EmailTokenReceivedEvent } from "../../TurnkeyModule";
import { useEffect } from "react";
import { useAuthRelay } from "../hooks/useAuthRelay";
import { TurnkeyConfigs } from "../sharedConfigs";
import { EmbeddedKeyAndNonce } from "./useEmbeddedKeyAndNonce";

interface EmailInputProps {
  initialValue?: string;
  onEmailChange: (email: string) => void;
  onValidationChange?: (isValid: boolean) => void;
  embeddedKeyAndNonce: EmbeddedKeyAndNonce;
  configs: TurnkeyConfigs;
}

export const EmailInput = ({
  initialValue,
  onEmailChange,
  onValidationChange,
  embeddedKeyAndNonce,
  configs,
}: EmailInputProps) => {
  const { completeOtpAuth } = useAuthRelay();

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

  const [email, setEmail] = React.useState(initialValue ?? "");

  const handleEmailChange = (text: string) => {
    setEmail(text);
    onEmailChange(text);

    const isValid = isValidEmail(text);
    onValidationChange?.(isValid);
  };


  return (
    <Input
      style={styles.emailInput}
      autoCapitalize="none"
      autoComplete="email"
      autoCorrect={false}
      keyboardType="email-address"
      placeholderTextColor="#888"
      placeholder="Enter your email"
      value={email}
      onChangeText={handleEmailChange}
      aria-labelledby="emailLabel"
      aria-errormessage="emailError"
    />
  );
};

const isValidEmail = (email: string | undefined) => {
  if (!email) return false;
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
