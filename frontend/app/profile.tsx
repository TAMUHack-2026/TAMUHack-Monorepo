// app/profile.tsx
import React, { useMemo, useRef, useState } from "react";
import { Alert } from "react-native";
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

function norm(v: string) {
  return v.trim();
}

function isValidAge(ageStr: string) {
  if (ageStr.trim() === "") return false;
  const n = Number(ageStr);
  return Number.isInteger(n) && n >= 0 && n <= 150;
}

function isValidHeight(v: string) {
  if (v.trim() === "") return false;
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) return false;
  return /^\d{1,4}(\.\d{1,2})?$/.test(v);
}

function isValidWeight(v: string) {
  if (v.trim() === "") return false;
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) return false;
  return /^\d{1,5}(\.\d{1,2})?$/.test(v);
}

function normalizeTwoDecimals(v: string) {
  const n = Number(v);
  if (!Number.isFinite(n)) return v;
  return n.toFixed(2);
}

export default function ProfileScreen() {
  const { profile, saveProfile, clearProfile } = useAppState();
  const insets = useSafeAreaInsets();

  // Local editable state
  const [email, setEmail] = useState(profile.email);
  const [height, setHeight] = useState(profile.height);
  const [weight, setWeight] = useState(profile.weight);
  const [age, setAge] = useState(profile.age);
  const [sex, setSex] = useState<SexValue>(profile.sex);

  // Track original values to detect whether user changed anything
  const initialRef = useRef(profile);

  const isDirty = useMemo(() => {
    const init = initialRef.current;
    return (
      norm(email) !== norm(init.email) ||
      norm(height) !== norm(init.height) ||
      norm(weight) !== norm(init.weight) ||
      norm(age) !== norm(init.age) ||
      norm(sex) !== norm(init.sex)
    );
  }, [email, height, weight, age, sex]);

  // Complete means "all filled" (only matters if dirty)
  const localComplete = useMemo(() => {
    return norm(email) !== "" && norm(height) !== "" && norm(weight) !== "" && norm(age) !== "" && norm(sex) !== "";
  }, [email, height, weight, age, sex]);

  // Validate with same constraints as Create Account (only matters if dirty)
  const errors = useMemo(() => {
    if (!isDirty) return {};

    const e: Record<string, string> = {};

    if (!email.includes("@")) e.email = "Please enter a valid email.";
    if (!isValidAge(age)) e.age = "Age must be an integer between 0 and 150.";
    if (!isValidHeight(height))
      e.height = "Height must be positive with up to 4 digits and up to 2 decimals (e.g., 70.50).";
    if (!isValidWeight(weight))
      e.weight = "Weight must be positive with up to 5 digits and up to 2 decimals (e.g., 170.25).";

    if (sex !== "Male" && sex !== "Female") e.sex = "Please select Male or Female.";

    // If they’re dirty but left blanks, show a single “fill all fields” message
    if (!localComplete) e.form = "Finish all fields before leaving or saving.";

    return e;
  }, [isDirty, email, age, height, weight, sex, localComplete]);

  const isValid = useMemo(() => {
    if (!isDirty) return true; // if they didn't edit, it's fine
    return Object.keys(errors).length === 0;
  }, [errors, isDirty]);

  // Status: Optional by default, then Complete/Incomplete once edited
  const status = useMemo<"Optional" | "Complete" | "Incomplete">(() => {
    if (!isDirty) return "Optional";
    return isValid ? "Complete" : "Incomplete";
  }, [isDirty, isValid]);

  function blockIfInvalid(): boolean {
    // returns true if we should block leaving/saving
    if (!isDirty) return false;
    if (isValid) return false;

    Alert.alert(
      "Incomplete",
      errors.form || "Please correct the highlighted fields before leaving."
    );
    return true;
  }

  async function tryLeave() {
    if (blockIfInvalid()) return;

    // If dirty and valid, auto-save before leaving
    if (isDirty) {
      await save(); // Reuse save logic
      return;
    }

    router.back();
  }

  async function save() {
    if (blockIfInvalid()) return;

    const newProfile = {
      email: norm(email),
      firstName: profile.firstName, // Maintain existing names
      lastName: profile.lastName,
      genderIdentity: profile.genderIdentity,
      height: norm(height),
      weight: norm(weight),
      age: norm(age),
      sex,
    };

    await saveProfile(newProfile);

    // Reset "dirty" baseline after save
    initialRef.current = newProfile;

    router.back();
  }

  function clearAll() {
    clearProfile();
    setEmail("");
    setHeight("");
    setWeight("");
    setAge("");
    setSex("");
  }

  return (
    <Box flex={1} bg="$background0" px="$5" pt={insets.top + 12}>
      <HStack alignItems="center" justifyContent="space-between" pb="$4">
        <HStack alignItems="center" space="md">
          <Pressable onPress={tryLeave} p="$2" hitSlop={10}>
            <Ionicons name="close" size={22} />
          </Pressable>
          <Heading size="lg">Personal Info</Heading>
        </HStack>

        <Text color={status === "Complete" ? "$success700" : status === "Incomplete" ? "$error600" : "$text500"}>
          {status}
        </Text>
      </HStack>

      <VStack space="md">
        <Input
          borderRadius="$xl"
          isInvalid={isDirty && (!!errors.email || !!errors.form)}
        >
          <InputField
            placeholder="Email Address"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
        </Input>
        {isDirty && errors.email ? (
          <Text mt="$1" color="$error600" fontSize="$sm">
            {errors.email}
          </Text>
        ) : null}

        <Input
          borderRadius="$xl"
          isInvalid={isDirty && (!!errors.height || !!errors.form)}
        >
          <InputField
            placeholder="Height in inches (e.g., 70.50)"
            value={height}
            onChangeText={(t) => setHeight(t.replace(/[^0-9.]/g, ""))}
            keyboardType="numbers-and-punctuation"
            onBlur={() => {
              if (height && isValidHeight(height)) setHeight(normalizeTwoDecimals(height));
            }}
          />
        </Input>
        {isDirty && errors.height ? (
          <Text mt="$1" color="$error600" fontSize="$sm">
            {errors.height}
          </Text>
        ) : null}

        <Input
          borderRadius="$xl"
          isInvalid={isDirty && (!!errors.weight || !!errors.form)}
        >
          <InputField
            placeholder="Weight in lbs (e.g., 170.25)"
            value={weight}
            onChangeText={(t) => setWeight(t.replace(/[^0-9.]/g, ""))}
            keyboardType="numbers-and-punctuation"
            onBlur={() => {
              if (weight && isValidWeight(weight)) setWeight(normalizeTwoDecimals(weight));
            }}
          />
        </Input>
        {isDirty && errors.weight ? (
          <Text mt="$1" color="$error600" fontSize="$sm">
            {errors.weight}
          </Text>
        ) : null}

        <Input borderRadius="$xl" isInvalid={isDirty && (!!errors.age || !!errors.form)}>
          <InputField
            placeholder="Age (0–150)"
            value={age}
            onChangeText={(t) => setAge(t.replace(/[^\d]/g, ""))}
            keyboardType="number-pad"
          />
        </Input>
        {isDirty && errors.age ? (
          <Text mt="$1" color="$error600" fontSize="$sm">
            {errors.age}
          </Text>
        ) : null}

        {/* Sex picker */}
        <Box
          borderWidth={1}
          borderColor={isDirty && (errors.sex || errors.form) ? "$error600" : "$border200"}
          borderRadius="$2xl"
          p="$3"
        >
          <Text mb="$2" color="$text600">
            Sex
          </Text>

          <HStack space="sm" flexWrap="wrap">
            {(["Male", "Female"] as SexValue[]).map((v) => {
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
        {isDirty && errors.sex ? (
          <Text mt="$1" color="$error600" fontSize="$sm">
            {errors.sex}
          </Text>
        ) : null}

        <VStack space="sm" mt="$2">
          <Button borderRadius="$xl" onPress={save} isDisabled={isDirty && !isValid}>
            <ButtonText>Save</ButtonText>
          </Button>

          <Button borderRadius="$xl" variant="outline" onPress={clearAll}>
            <ButtonText>Clear Info</ButtonText>
          </Button>

          {isDirty && !isValid ? (
            <Text color="$text500">{errors.form || "Please fix the highlighted fields."}</Text>
          ) : null}
        </VStack>
      </VStack>
    </Box>
  );
}
