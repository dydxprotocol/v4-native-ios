import { SafeAreaProvider } from "react-native-safe-area-context";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { TurnkeyProvider } from "@turnkey/sdk-react-native";
import React from "react";
import { TurnkeyConfigs } from '../sharedConfigs';


export const Providers = ({ children, configs }: { children: React.ReactNode, configs: TurnkeyConfigs }) => {

    const sessionConfig = {
        apiBaseUrl: configs.turnkeyUrl,
        organizationId: configs.turnkeyOrgId,
        onSessionSelected: () => {
            console.log("onSessionSelected");
        },
        onSessionCleared: () => {
            console.log("onSessionCleared");
        },
    };

    return (
        <TurnkeyProvider config={sessionConfig}>
            {children}
        </TurnkeyProvider>
    );
};
