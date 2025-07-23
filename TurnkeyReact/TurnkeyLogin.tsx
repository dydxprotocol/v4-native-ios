import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  NativeSyntheticEvent,
  TextInputChangeEventData,
} from 'react-native';
import FontAwesome from 'react-native-vector-icons/FontAwesome';
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { OAuth } from './components/Oauth';
import { Providers } from './providers/providers';
import { styles } from "./turnkeyStyle";
import "react-native-get-random-values";
import { TurnkeyConfigs } from './sharedConfigs';


export const TurnkeyLogin = (configs: TurnkeyConfigs) => {
  const [email, setEmail] = useState<string>('');

  const handleEmailChange = (text: string) => {
    setEmail(text);
  };

  function loginWithOAuth(params: { oidcToken: string; providerName: string; targetPublicKey: string; expirationSeconds: string; }): Promise<void> {
    console.log('OAuth login with params:', params);
    return Promise.resolve();
  }

  return (
    <Providers configs={configs}>
      <ScrollView contentContainerStyle={styles.container}>
        {/* Header */}
        <Text style={styles.title}>Sign in</Text>
        <Text style={styles.subtitle}>
          To get started, sign in with your social accounts, create a passkey or
          connect your wallet.
        </Text>

        {/* Social icons row */}
        <View style={styles.socialRow}>
          <OAuth onSuccess={loginWithOAuth} configs={configs} />
        </View>

        {/* Email input row */}
        <View style={styles.emailRow}>
          <TextInput
            style={styles.emailInput}
            placeholder="your@email.com"
            placeholderTextColor="#888"
            value={email}
            onChangeText={handleEmailChange}
            keyboardType="email-address"
          />
          <TouchableOpacity style={styles.submitButton}>
            <Text style={styles.submitButtonText}>Submit</Text>
          </TouchableOpacity>
        </View>

        {/* Divider */}
        <View style={styles.dividerContainer}>
          <View style={styles.divider} />
          <Text style={styles.dividerText}>Or</Text>
          <View style={styles.divider} />
        </View>

        {/* Sign in with Passkey */}
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons
            name="person"
            size={18}
            color="#fff"
            style={{ marginRight: 8 }}
          />
          <Text style={styles.actionButtonText}>Sign in with Passkey</Text>
        </TouchableOpacity>

        {/* Sign in with Wallet */}
        <TouchableOpacity style={styles.actionButton}>
          <Ionicons
            name="wallet"
            size={18}
            color="#fff"
            style={{ marginRight: 8 }}
          />
          <Text style={styles.actionButtonText}>Sign in with Wallet</Text>
        </TouchableOpacity>
      </ScrollView>
    </Providers>
  );
};