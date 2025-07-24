

import { Auth } from './components/Auth';
import { Providers } from './providers/providers';
import "react-native-get-random-values";
import { TurnkeyConfigs } from './sharedConfigs';

export const TurnkeyLogin = (configs: TurnkeyConfigs) => {
  return (
    <Providers configs={configs}>
      <Auth configs={configs} />
    </Providers>
  );
};

