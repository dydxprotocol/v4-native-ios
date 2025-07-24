import * as React from "react";
import { Input } from "../components/ui/input";
import { styles } from "../turnkeyStyle";

interface EmailInputProps {
  initialValue?: string;
  onEmailChange: (email: string) => void;
  onValidationChange?: (isValid: boolean) => void;
}

export const EmailInput = ({
  initialValue,
  onEmailChange,
  onValidationChange,
}: EmailInputProps) => {
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
