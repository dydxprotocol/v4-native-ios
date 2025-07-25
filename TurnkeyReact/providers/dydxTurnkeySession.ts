
import { ApiKeyStamper } from "@turnkey/api-key-stamper";
import { TurnkeyClient } from "@turnkey/http";
import { _TypedDataEncoder } from "ethers/lib/utils";

export class DydxTurnkeySession {
  private stamper: ApiKeyStamper;
  private client: TurnkeyClient;

  constructor(privateKey: string, publicKey: string) {
    this.stamper = new ApiKeyStamper({
      apiPublicKey: publicKey,
      apiPrivateKey: privateKey,
    });

    this.client = new TurnkeyClient(
      { baseUrl: "https://api.turnkey.com" },
      this.stamper,
    );
  }

  async signOnboardingMessage(): Promise<string>   {
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

    return Promise.resolve(digest);
    // return this.client.signRawPayload({
    //   signWith: "onboarding",
    //   payload: digest,
    //   encoding: "hex",
    //   hashFunction: "keccak256",
    // });
  }
}

