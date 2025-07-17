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

export function TurnkeyLogin(): React.JSX.Element {
  return <SignInScreen />;
}

const SignInScreen: React.FC = () => {
  const [email, setEmail] = useState<string>('');

  const handleEmailChange = (text: string) => {
    setEmail(text);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      {/* Header */}
      <Text style={styles.title}>Sign in</Text>
      <Text style={styles.subtitle}>
        To get started, sign in with your social accounts, create a passkey or
        connect your wallet.
      </Text>

      {/* Social icons row */}
      <View style={styles.socialRow}>
        <TouchableOpacity style={styles.socialButton}>
          <FontAwesome name="apple" size={24} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.socialButton}>
          <FontAwesome name="google" size={24} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.socialButton}>
          <MaterialIcons name="close" size={24} color="#fff" />
        </TouchableOpacity>
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
  );
};

export default SignInScreen;

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: '#1c1c1e',
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    color: '#fff',
    fontWeight: '600',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#aaa',
    marginBottom: 24,
  },
  socialRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 20,
  },
  socialButton: {
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    padding: 12,
  },
  emailRow: {
    flexDirection: 'row',
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 24,
  },
  emailInput: {
    flex: 1,
    paddingHorizontal: 12,
    color: '#fff',
  },
  submitButton: {
    backgroundColor: '#3a3a3c',
    justifyContent: 'center',
    paddingHorizontal: 12,
  },
  submitButtonText: {
    color: '#fff',
    fontWeight: '500',
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
  },
  divider: {
    flex: 1,
    height: 1,
    backgroundColor: '#333',
  },
  dividerText: {
    color: '#888',
    marginHorizontal: 8,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    padding: 14,
    marginBottom: 12,
  },
  actionButtonText: {
    color: '#fff',
    fontSize: 16,
  },
});
