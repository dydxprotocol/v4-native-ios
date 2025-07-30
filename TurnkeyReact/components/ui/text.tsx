import * as Slot from "@rn-primitives/slot";
import type { SlottableTextProps, TextRef } from "@rn-primitives/types";
import * as React from "react";
import { Text as RNText } from "react-native";
import { styles } from '../../../rn_style/dydxStyle';

const TextClassContext = React.createContext<string | undefined>(undefined);

const Text = React.forwardRef<TextRef, SlottableTextProps>(
  ({ asChild = false, style, ...props }, ref) => {
    const textClass = React.useContext(TextClassContext);
    const Component = asChild ? Slot.Text : RNText;
    return (
      <Component
        ref={ref}
        {...props}
        style={[
          { fontFamily: 'Satoshi-Regular' }, // default font
          textClass && styles[textClass as keyof typeof styles],    // resolve text class (if using StyleSheet)
          style,                              // override last
        ]}
      />
    );
  },
);
Text.displayName = "Text";

export { Text, TextClassContext };
