
import { ApiKeyStamper } from "@turnkey/api-key-stamper";
import { TurnkeyClient } from "@turnkey/http";
import { _TypedDataEncoder } from "ethers/lib/utils";
import { TurnkeyConfigs } from "../sharedConfigs";

export class DydxTurnkeySession {
  private stamper: ApiKeyStamper;
  private client: TurnkeyClient;

  constructor(privateKey: string, publicKey: string, configs: TurnkeyConfigs) {
    this.stamper = new ApiKeyStamper({
      apiPublicKey: publicKey,
      apiPrivateKey: privateKey,
    });

    this.client = new TurnkeyClient(
      { baseUrl: configs.turnkeyUrl },
      this.stamper,
    );
  }

  async signOnboardingMessage(walletAccountAddress: string): Promise<string> {
    const onboardingTypedData = {
      primaryType: 'dYdX',
      domain: {
        name: 'dYdX Chain',
      },
      types: {
        dYdX: [
          { name: 'action', type: 'string' },
        ],
      },
      message: {
        action: 'dYdX Chain Onboarding',
      },
    };

    // Hash the typed message, keccak256 encoded
    const digest = _TypedDataEncoder.hash(
      onboardingTypedData.domain,
      onboardingTypedData.types,
      onboardingTypedData.message
    );

    console.log('Digest:', digest); // 0x-prefixed 32-byte hex

    const response = this.client.signRawPayload({
      type: "ACTIVITY_TYPE_SIGN_RAW_PAYLOAD_V2",
      /** @description Timestamp (in milliseconds) of the request, used to verify liveness of user requests. */
      timestampMs: "",
      /** @description Unique identifier for a given Organization. */
      organizationId: "",
      parameters: {
        signWith: walletAccountAddress,
        payload: digest,
        encoding: "PAYLOAD_ENCODING_HEXADECIMAL",
        hashFunction: "HASH_FUNCTION_NO_OP",
      }
    });

    return Promise.resolve("");
  }
}

