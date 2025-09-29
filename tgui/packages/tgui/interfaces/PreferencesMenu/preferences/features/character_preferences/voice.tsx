import { Box, Button, Slider, Stack } from '../../../../../components';

import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumeric,
  FeatureNumericData,
  FeatureValueProps,
} from '../base';

const FeatureBarkDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_bark');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('open_voice_screen');
          }}
          width="100%"
          height="100%"
        >
          {props.value}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const voice_pack: FeatureChoiced = {
  name: 'Voice (disable in settings)',
  component: FeatureBarkDropdownInput,
};

const FeatureSliderInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>,
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <Slider
      onChange={(_, value: number) => {
        props.handleSetValue(value);
      }}
      minValue={props.serverData.minimum}
      maxValue={props.serverData.maximum}
      step={props.serverData.step}
      value={props.value}
    />
  );
};

export const bark_pitch_range: FeatureNumeric = {
  name: 'Voice Pitch Range - default 0.2',
  component: FeatureSliderInput,
};

export const bark_speech_speed: FeatureNumeric = {
  name: 'Voice Duration - default 6',
  component: FeatureSliderInput,
};

export const bark_speech_pitch: FeatureNumeric = {
  name: 'Voice Pitch - default 1',
  component: FeatureSliderInput,
};
