import { useTurnkey } from "@turnkey/sdk-react-native";
import { TurnkeyConfigs } from "../SharedConfigs";
import { Button } from "./ui/button";
import { View, Text } from "react-native";
// import GoogleIcon from "../assets/svgs/google.svg";
import { styles } from "../turnkeyStyle";
import { OAuthRequest } from "../providers/authRelayProvider";
import { EmbeddedKeyAndNonce, useEmbeddedKeyAndNonce } from "./useEmbeddedKeyAndNonce";

type OAuthProps = {
  onSuccess: (params: OAuthRequest) => Promise<void>;
  configs: TurnkeyConfigs;
  embeddedKeyAndNonce: EmbeddedKeyAndNonce;
}

export const GoogleAuthButton: React.FC<OAuthProps> = ({
  onSuccess,
  configs,
  embeddedKeyAndNonce
}: OAuthProps) => {
  const { handleGoogleOAuth } = useTurnkey();

  const handlePress = async () => {
    try {
      await handleGoogleOAuth({
        clientId: configs.googleClientId,
        nonce: embeddedKeyAndNonce.nonce!,
        scheme: configs.appScheme,
        onSuccess: async (idToken: string) => {
          await onSuccess({
            oidcToken: idToken,
            providerName: "google",
            embeddedKeyAndNonce: embeddedKeyAndNonce,
            configs: configs,
          });

          // we refresh the nonce before authentication to ensure a new one is used
          // if the user logs out and logs in with oAuth again
          await embeddedKeyAndNonce.refreshNonce();
        },
      });
    } catch (error) {
      console.error("Error in Google Auth:", error);
    }
  };

  return (
    <Button
      onPress={handlePress}
      // className="border border-black rounded-xl bg-transparent flex-row items-center justify-center flex-1 h-16"
      disabled={embeddedKeyAndNonce.nonce == null || !embeddedKeyAndNonce.targetPublicKey}
    >
      {/* <GoogleIcon width={24} height={24} /> */}
      <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "center" }}>
        <Text style={styles.subtitle}>Google</Text>
      </View>
    </Button>
  );
};

export const OAuthInput: React.FC<OAuthProps> = (props) => {
  const { onSuccess, configs, embeddedKeyAndNonce } = props;

  return (
    // <View className="flex flex-row items-center justify-center w-full gap-4">
    <View>
      <GoogleAuthButton
        onSuccess={onSuccess}
        configs={configs}
        embeddedKeyAndNonce={embeddedKeyAndNonce}
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
