import { ReactNode, createContext, useReducer } from "react";
import { LoginMethod } from "../lib/types";
import {
  User,
  useTurnkey,
} from "@turnkey/sdk-react-native";
import { TurnkeyNativeModule } from "../../TurnkeyModule";
import { DydxTurnkeySession } from "./dydxTurnkeySession";
import { EmbeddedKeyAndNonce } from "../components/useEmbeddedKeyAndNonce";
import { TurnkeyConfigs } from "../sharedConfigs";

type AuthActionType =
  | { type: "PASSKEY"; payload: User }
  | { type: "INIT_EMAIL_AUTH" }
  | { type: "COMPLETE_EMAIL_AUTH"; payload: User }
  | { type: "INIT_PHONE_AUTH" }
  | { type: "COMPLETE_PHONE_AUTH"; payload: User }
  | { type: "EMAIL_RECOVERY"; payload: User }
  | { type: "WALLET_AUTH"; payload: User }
  | { type: "OAUTH"; payload: User }
  | { type: "LOADING"; payload: LoginMethod | null }
  | { type: "ERROR"; payload: string }
  | { type: "CLEAR_ERROR" };
interface AuthState {
  loading: LoginMethod | null;
  error: string;
  user: User | null;
}

const initialState: AuthState = {
  loading: null,
  error: "",
  user: null,
};

function authReducer(state: AuthState, action: AuthActionType): AuthState {
  switch (action.type) {
    case "LOADING":
      return { ...state, loading: action.payload ? action.payload : null };
    case "ERROR":
      return { ...state, error: action.payload, loading: null };
    case "CLEAR_ERROR":
      return { ...state, error: "" };
    case "INIT_EMAIL_AUTH":
      return { ...state, loading: null, error: "" };
    case "COMPLETE_EMAIL_AUTH":
      return { ...state, user: action.payload, loading: null, error: "" };
    case "INIT_PHONE_AUTH":
      return { ...state, loading: null, error: "" };
    case "COMPLETE_PHONE_AUTH":
      return { ...state, user: action.payload, loading: null, error: "" };
    case "OAUTH":
    case "PASSKEY":
    case "EMAIL_RECOVERY":
    case "WALLET_AUTH":
    case "OAUTH":
      return { ...state, user: action.payload, loading: null, error: "" };
    default:
      return state;
  }
}

export type OAuthRequest = {
  oidcToken: string;
  providerName: string;
  targetPublicKey: string;
  configs: TurnkeyConfigs;
};

export type OtpAuthRequest = {
  otpType: string;
  contact: string;
  embeddedKeyAndNonce: EmbeddedKeyAndNonce;
  configs: TurnkeyConfigs;
};

export interface AuthRelayProviderType {
  state: AuthState;
  initOtpLogin: (params: OtpAuthRequest) => Promise<void>;
  completeOtpAuth: (params: {
    otpId: string;
    otpCode: string;
    organizationId: string;
  }) => Promise<void>;
  signUpWithPasskey: () => Promise<void>;
  loginWithPasskey: () => Promise<void>;
  loginWithOAuth: (params: OAuthRequest) => Promise<void>;
  clearError: () => void;
}

export const AuthRelayContext = createContext<AuthRelayProviderType>({
  state: initialState,
  initOtpLogin: async () => Promise.resolve(),
  completeOtpAuth: async () => Promise.resolve(),
  signUpWithPasskey: async () => Promise.resolve(),
  loginWithPasskey: async () => Promise.resolve(),
  loginWithOAuth: async () => Promise.resolve(),
  clearError: () => { },
});

interface AuthRelayProviderProps {
  children: ReactNode;
}

export const AuthRelayProvider: React.FC<AuthRelayProviderProps> = ({
  children,
}) => {
  const [state, dispatch] = useReducer(authReducer, initialState);
  const { createEmbeddedKey, createSession, createSessionFromEmbeddedKey } =
    useTurnkey();

  const initOtpLogin = async ({
    otpType,
    contact,
    embeddedKeyAndNonce,
    configs,
  }: OtpAuthRequest) => {

    const inputBody = {
      "signinMethod": "email",
      "userEmail": contact,
      "targetPublicKey": embeddedKeyAndNonce.targetPublicKey,
    };
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    //sendSignInRequest(headers, JSON.stringify(inputBody), configs);
  };

  const completeOtpAuth = async ({
    otpId,
    otpCode,
    organizationId,
  }: {
    otpId: string;
    otpCode: string;
    organizationId: string;
  }) => {
    console.debug("completeOtpAuth called with:", otpId, otpCode, organizationId);
  };

  // User will be prompted once for passkey creation then will leverage an api key session to have a smooth "one tap" login experience
  const signUpWithPasskey = async () => {
    console.debug("signUpWithPasskey called");
  };

  const loginWithPasskey = async () => {
    console.debug("loginWithPasskey called");
  };

  const loginWithOAuth = async ({
    oidcToken,
    providerName,
    targetPublicKey,
    configs,
  }: OAuthRequest) => {
    // const dydxSession = new DydxTurnkeySession(
    //   targetPublicKey,
    //   targetPublicKey,
    // );
    // const hash = await dydxSession.signOnboardingMessage();
    const inputBody = {
      "signinMethod": "social",
      "targetPublicKey": targetPublicKey,
      "provider": providerName,
      "oidcToken": oidcToken,
    };
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    sendSignInRequest(headers, JSON.stringify(inputBody), configs);
  };

  const sendSignInRequest = async (
    headers: HeadersInit,
    body: string,
    configs: TurnkeyConfigs
  ) => {
    dispatch({ type: "LOADING", payload: LoginMethod.OAuth });
    try {
      const response = await fetch(`${configs.backendApiUrl}/v4/turnkey/signin`, {
        method: "POST",
        headers: headers,
        body: body,
      }).then((res) => res.json());

      console.debug("Sign-in response:", response);

      if (response.errors && Array.isArray(response.errors)) {
        // Handle API-reported errors
        const errorMsg = response.errors.map((e: { msg: any; }) => e.msg).join(", ");
        throw new Error(`Backend Error: ${errorMsg}`);
      }

      const salt = response.salt;
      if (!salt) {
        throw new Error("No salt provided in response");
      }
      const credentialBundle = response.session;
      if (!credentialBundle) {
        throw new Error("No credential bundle provided in response");
      }

      const decodedSession = decodeSessionJwt(credentialBundle);
      console.debug("Decoded session:", decodedSession);

      const session = await createSession({ bundle: credentialBundle });
      console.debug("Session created:", session);

    } catch (error: any) {
      console.error("Error during sign-in:", error);
      dispatch({ type: "ERROR", payload: error.message });
    } finally {
      dispatch({ type: "LOADING", payload: null });
    }
  }

  const clearError = () => {
    dispatch({ type: "CLEAR_ERROR" });
  };

   function decodeSessionJwt(token: string): {
    sessionType: string;
    userId: string;
    organizationId: string;
    expiry: number;
    publicKey: string;
  } {
    const [, payload] = token.split(".");
    if (!payload) {
      throw new Error("Invalid JWT: Missing payload");
    }

    const decoded = JSON.parse(atob(payload));
    const {
      exp,
      public_key: publicKey,
      session_type: sessionType,
      user_id: userId,
      organization_id: organizationId,
    } = decoded;

    if (!exp || !publicKey || !sessionType || !userId || !organizationId) {
      throw new Error("JWT payload missing required fields");
    }

    return {
      sessionType,
      userId,
      organizationId,
      expiry: exp,
      publicKey,
    };
  }

  return (
    <AuthRelayContext.Provider
      value={{
        state,
        initOtpLogin,
        completeOtpAuth,
        signUpWithPasskey,
        loginWithPasskey,
        loginWithOAuth,
        clearError,
      }}
    >
      {children}
    </AuthRelayContext.Provider>
  );
};
