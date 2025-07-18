import { useTurnkey } from "@turnkey/sdk-react-native";
import { useEffect, useState, useCallback } from "react";
import { SharedConfigs } from "./SharedConfigs";
import { Button } from "./ui/button";
import { View, Text } from "react-native";
import GoogleIcon from "../assets/svgs/google.svg";
import { OAUTH_TOKEN_EXPIRATION_SECONDS } from "./lib/constants";
// import * as Crypto from "expo-crypto";
import { styles } from "./TurnkeyStyle";
import SHA256 from 'crypto-js/sha256';

type OAuthProps =  {
  onSuccess: (params: {
    oidcToken: string;
    providerName: string;
    targetPublicKey: string;
    expirationSeconds: string;
  }) => Promise<void>;
  configs: SharedConfigs;
}
type AuthButtonProps = {
  nonce: string | null;
  targetPublicKey: string | null;
  refreshNonce: () => Promise<void>;
} & OAuthProps;

export const GoogleAuthButton: React.FC<AuthButtonProps> = ({
  onSuccess,
  nonce,
  targetPublicKey,
  refreshNonce,
  configs,
}) => {
  const { handleGoogleOAuth } = useTurnkey();

  const onIdToken = async (idToken: string) => {
    await onSuccess({
      oidcToken: idToken,
      providerName: "google",
      targetPublicKey: targetPublicKey!,
      expirationSeconds: OAUTH_TOKEN_EXPIRATION_SECONDS,
    });

    // we refresh the nonce before authentication to ensure a new one is used
    // if the user logs out and logs in with oAuth again
    await refreshNonce();
  };

  const handlePress = async () => {
    try {
      await handleGoogleOAuth({
        clientId: configs.googleClientId,
        nonce: nonce!,
        scheme: configs.appScheme,
        onSuccess: onIdToken,
      });
    } catch (error) {
      console.error("Error in Google Auth:", error);
    }
  };

  return (
    <Button
      onPress={handlePress}
     // className="border border-black rounded-xl bg-transparent flex-row items-center justify-center flex-1 h-16"
      disabled={nonce == null || !targetPublicKey}
    >
        {/* <GoogleIcon width={24} height={24} /> */}
      <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "center" }}>
        <Text style={styles.subtitle}>Google</Text>
      </View>
    </Button>
  );
};

/**
 * The nonce is a unique, cryptographically secure string used to ensure the authenticity and integrity
 * of each authentication request. In our implementation, we generate the nonce by hashing the embedded public key.
 *
 * Key purposes:
 * 1. Prevent Replay Attacks: By using a unique nonce per session, we help ensure that an intercepted token
 *    cannot be reused maliciously.
 * 2. Tie the Authentication Request to the Response: The nonce is included in the OAuth flow so that the identity token
 *    received from providers (Google or Apple) is bound to the specific authentication request.
 *
 * After a successful authentication, the nonce is refreshed to guarantee that every new authentication flow uses
 * a unique value.
 */
export const useEmbeddedKeyAndNonce = () => {
  const { createEmbeddedKey } = useTurnkey();

  const [targetPublicKey, setTargetPublicKey] = useState<string | null>(null);
  const [nonce, setNonce] = useState<string | null>(null);

  const generateNonce = useCallback(async () => {
    try {
      const pubKey = await createEmbeddedKey();
      setTargetPublicKey(pubKey);

      const hashedNonce = SHA256(pubKey).toString();
    //   const hashedNonce = await Crypto.digestStringAsync(
    //     Crypto.CryptoDigestAlgorithm.SHA256,
    //     pubKey
    //   );
      setNonce(hashedNonce);
    } catch (error) {
      console.error("Error generating nonce and public key:", error);
    }
  }, [createEmbeddedKey]);

  useEffect(() => {
    generateNonce();
  }, [generateNonce]);

  return { targetPublicKey, nonce, refreshNonce: generateNonce };
};


export const OAuth: React.FC<OAuthProps> = (props) => {
  const { onSuccess, configs } = props;

  const { targetPublicKey, nonce, refreshNonce } = useEmbeddedKeyAndNonce();

  return (
   // <View className="flex flex-row items-center justify-center w-full gap-4">
    <View>
      <GoogleAuthButton
        onSuccess={onSuccess}
        nonce={nonce}
        targetPublicKey={targetPublicKey}
        refreshNonce={refreshNonce}
        configs={configs}
      />
      {/* <AppleAuthButton
        onSuccess={onSuccess}
        nonce={nonce}
        targetPublicKey={targetPublicKey}
        refreshNonce={refreshNonce}
      /> */}
    </View>
  );
};
