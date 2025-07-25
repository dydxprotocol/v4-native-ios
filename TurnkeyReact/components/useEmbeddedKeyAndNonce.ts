import { useTurnkey } from "@turnkey/sdk-react-native";
import { SHA256 } from "crypto-js";
import { useCallback, useEffect, useState } from "react";

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

export type EmbeddedKeyAndNonce = {
  targetPublicKey: string | null;
  nonce: string | null;
  refreshNonce: () => Promise<void>;
};

export const useEmbeddedKeyAndNonce = (): EmbeddedKeyAndNonce => {
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
