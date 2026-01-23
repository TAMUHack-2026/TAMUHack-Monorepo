import React, { useMemo, useState } from "react";
import { router } from "expo-router";
import {
  Box,
  Button,
  ButtonText,
  Heading,
  HStack,
  Input,
  InputField,
  Pressable,
  Text,
  VStack,
} from "@gluestack-ui/themed";
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { SexValue, useAppState } from "../src/state/AppState";

export default function ProfileScreen() {
  const { profile, setProfile, isProfileComplete, clearProfile } = useAppState();
  const insets = useSafeAreaInsets();

  const [height, setHeight] = useState(profile.height);
  const [weight, setWeight] = useState(profile.weight);
  const [age, setAge] = useState(profile.age);
  const [sex, setSex] = useState<SexValue>(profile.sex);

  const localComplete = useMemo(() => {
    return (
      height.trim() !== "" &&
      weight.trim() !== "" &&
      age.trim() !== "" &&
      sex.trim() !== ""
    );
  }, [height, weight, age, sex]);

  function save() {
    setProfile({
      height: height.trim(),
      weight: weight.trim(),
      age: age.trim(),
      sex,
    });
    router.back();
  }

  function clearAll() {
    clearProfile();
    setHeight("");
    setWeight("");
    setAge("");
    setSex("");
  }

  return (
    <Box flex={1} bg="$background0" px="$5" pt={insets.top + 12}>
      <HStack alignItems="center" justifyContent="space-between" pb="$4">
        <HStack alignItems="center" space="md">
          <Pressable onPress={() => router.back()} p="$2" hitSlop={10}>
            <Ionicons name="close" size={22} />
          </Pressable>
          <Heading size="lg">Personal Info</Heading>
        </HStack>

        <Text color={isProfileComplete ? "$success700" : "$error600"}>
          {isProfileComplete ? "Complete" : "Incomplete"}
        </Text>
      </HStack>

      <VStack space="md">
        <Input borderRadius="$xl">
          <InputField
            placeholder="Height (e.g., 170 cm)"
            value={height}
            onChangeText={setHeight}
            keyboardType="numbers-and-punctuation"
          />
        </Input>

        <Input borderRadius="$xl">
          <InputField
            placeholder="Weight (e.g., 70 kg)"
            value={weight}
            onChangeText={setWeight}
            keyboardType="numbers-and-punctuation"
          />
        </Input>

        <Input borderRadius="$xl">
          <InputField
            placeholder="Age"
            value={age}
            onChangeText={setAge}
            keyboardType="number-pad"
          />
        </Input>

        {/* Sex picker */}
        <Box
          borderWidth={1}
          borderColor="$border200"
          borderRadius="$2xl"
          p="$3"
        >
          <Text mb="$2" color="$text600">
            Sex
          </Text>

          <HStack space="sm" flexWrap="wrap">
            {(["Male", "Female", "Other"] as SexValue[]).map((v) => {
              const selected = sex === v;
              return (
                <Button
                  key={v}
                  size="sm"
                  borderRadius="$xl"
                  variant={selected ? "solid" : "outline"}
                  onPress={() => setSex(v)}
                >
                  <ButtonText>{v}</ButtonText>
                </Button>
              );
            })}
          </HStack>
        </Box>

        <VStack space="sm" mt="$2">
          <Button borderRadius="$xl" onPress={save} isDisabled={!localComplete}>
            <ButtonText>Save</ButtonText>
          </Button>

          <Button borderRadius="$xl" variant="outline" onPress={clearAll}>
            <ButtonText>Clear Info</ButtonText>
          </Button>

          {!localComplete && (
            <Text color="$text500">Enter all fields to enable Save.</Text>
          )}
        </VStack>
      </VStack>
    </Box>
  );
}


