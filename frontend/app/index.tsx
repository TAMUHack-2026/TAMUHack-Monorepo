// app/index.tsx
import React, { useEffect, useMemo, useState } from "react";
import { router } from "expo-router";
import { KeyboardAvoidingView, Platform } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  Box,
  Button,
  ButtonText,
  Center,
  Divider,
  Heading,
  HStack,
  Input,
  InputField,
  ScrollView,
  Select,
  SelectBackdrop,
  SelectContent,
  SelectDragIndicator,
  SelectDragIndicatorWrapper,
  SelectInput,
  SelectItem,
  SelectPortal,
  SelectTrigger,
  Text,
  VStack,
} from "@gluestack-ui/themed";
import { Ionicons } from "@expo/vector-icons";

type Sex = "male" | "female";

const EMAIL_STORAGE_KEY = "user_email";

function isValidEmail(email: string) {
  const e = email.trim();
  if (e === "") return false;
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e);
}

function isValidAge(ageStr: string) {
  if (ageStr.trim() === "") return false;
  const n = Number(ageStr);
  return Number.isInteger(n) && n >= 0 && n <= 150;
}

function isValidHeightIn(v: string) {
  if (v.trim() === "") return false;
  const n = Number(v);
  if (!Number.isFinite(n) || n <= 0) return false;
  return /^\d{1,4}(\.\d{1,2})?$/.test(v);
}

function isValidWeightLbs(v: string) {
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

function Label({
  children,
  required,
}: {
  children: React.ReactNode;
  required?: boolean;
}) {
  return (
    <HStack alignItems="center" space="xs" mb="$1">
      <Text color="$text600">{children}</Text>
      {required ? <Text color="$error600">*</Text> : null}
    </HStack>
  );
}

export default function CreateAccountScreen() {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");

  const [age, setAge] = useState("");
  const [sex, setSex] = useState<Sex | "">("");

  const [genderIdentity, setGenderIdentity] = useState("");
  const [heightIn, setHeightIn] = useState("");
  const [weightLbs, setWeightLbs] = useState("");

  // If we already have an email stored, skip this screen.
  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        const stored = await AsyncStorage.getItem(EMAIL_STORAGE_KEY);
        if (!cancelled && stored && stored.trim() !== "") {
          router.replace("/dashboard");
        }
      } catch (err) {
        console.log("AsyncStorage read error:", err);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const errors = useMemo(() => {
    const e: Record<string, string> = {};

    if (firstName.trim() === "") e.firstName = "First name is required.";
    if (lastName.trim() === "") e.lastName = "Last name is required.";
    if (!isValidEmail(email)) e.email = "Please enter a valid email address.";

    if (!isValidAge(age)) e.age = "Age must be an integer between 0 and 150.";

    if (sex !== "male" && sex !== "female")
      e.sex = "Please select male or female.";

    if (!isValidHeightIn(heightIn))
      e.heightIn =
        "Height must be positive with up to 4 digits and up to 2 decimals (e.g., 70.50).";

    if (!isValidWeightLbs(weightLbs))
      e.weightLbs =
        "Weight must be positive with up to 5 digits and up to 2 decimals (e.g., 170.25).";

    return e;
  }, [firstName, lastName, email, age, sex, heightIn, weightLbs]);

  const isValid = Object.keys(errors).length === 0;

  async function submit() {
    if (!isValid) return;

    const normalizedEmail = email.trim().toLowerCase();

    try {
      await AsyncStorage.setItem(EMAIL_STORAGE_KEY, normalizedEmail);
    } catch (err) {
      console.log("AsyncStorage write error:", err);
      return;
    }

    const payload = {
      first_name: firstName.trim(),
      last_name: lastName.trim(),
      email: normalizedEmail,
      age: Number(age),
      sex: sex as Sex,
      gender_identity: genderIdentity.trim() || null,
      height_in: Number(heightIn),
      weight_lbs: Number(weightLbs),
    };

    console.log("CREATE_ACCOUNT_PAYLOAD (MVP):", payload);
    router.replace("/dashboard");
  }

  return (
    <Box flex={1} bg="$background0">
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === "ios" ? "padding" : "height"}
      >
        <ScrollView
          keyboardShouldPersistTaps="handled"
          contentContainerStyle={{ flexGrow: 1 }}
        >
          <Center flex={1} px="$6" py="$6">
            <Box w="$full" maxWidth={520}>
              {/* Header */}
              <HStack alignItems="center" space="md" mb="$5">
                <Box
                  w={44}
                  h={44}
                  borderRadius="$xl"
                  bg="$primary600"
                  alignItems="center"
                  justifyContent="center"
                >
                  <Ionicons name="pulse-outline" size={22} color="white" />
                </Box>

                <Box flex={1}>
                  <Heading size="xl">Create account</Heading>
                  <Text color="$text500">
                    Fields marked with <Text color="$error600">*</Text> are
                    required.
                  </Text>
                </Box>
              </HStack>

              {/* Form card */}
              <Box
                borderWidth={1}
                borderColor="$border200"
                borderRadius="$2xl"
                bg="$background0"
                p="$6"
              >
                <VStack space="md">
                  <HStack space="md">
                    <Box flex={1}>
                      <Label required>First name</Label>
                      <Input borderRadius="$xl" isInvalid={!!errors.firstName}>
                        <InputField
                          placeholder="John"
                          value={firstName}
                          onChangeText={setFirstName}
                          autoCapitalize="words"
                        />
                      </Input>
                      {!!errors.firstName && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.firstName}
                        </Text>
                      )}
                    </Box>

                    <Box flex={1}>
                      <Label required>Last name</Label>
                      <Input borderRadius="$xl" isInvalid={!!errors.lastName}>
                        <InputField
                          placeholder="Doe"
                          value={lastName}
                          onChangeText={setLastName}
                          autoCapitalize="words"
                        />
                      </Input>
                      {!!errors.lastName && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.lastName}
                        </Text>
                      )}
                    </Box>
                  </HStack>

                  <Box>
                    <Label required>Email</Label>
                    <Input borderRadius="$xl" isInvalid={!!errors.email}>
                      <InputField
                        placeholder="john.doe@email.com"
                        value={email}
                        onChangeText={setEmail}
                        autoCapitalize="none"
                        keyboardType="email-address"
                      />
                    </Input>
                    {!!errors.email && (
                      <Text mt="$1" color="$error600" fontSize="$sm">
                        {errors.email}
                      </Text>
                    )}
                  </Box>

                  <HStack space="md">
                    <Box flex={1}>
                      <Label required>Age</Label>
                      <Input borderRadius="$xl" isInvalid={!!errors.age}>
                        <InputField
                          placeholder="25"
                          value={age}
                          onChangeText={(t) => setAge(t.replace(/[^\d]/g, ""))}
                          keyboardType="number-pad"
                        />
                      </Input>
                      {!!errors.age && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.age}
                        </Text>
                      )}
                    </Box>

                    <Box flex={1}>
                      <Label required>Sex</Label>

                      <Select
                        selectedValue={sex}
                        onValueChange={(v) => setSex(v as Sex)}
                      >
                        <SelectTrigger
                          variant="outline"
                          size="md"
                          borderRadius="$xl"
                          borderWidth={errors.sex ? 2 : 1}
                          sx={{
                            borderColor: errors.sex ? "$error600" : "$border200",
                          }}
                        >
                          {/* FIX: don't use SelectIcon; it doesn't forward props in your version */}
                          <HStack
                            flex={1}
                            alignItems="center"
                            justifyContent="space-between"
                          >
                            <SelectInput placeholder="Select sex" />
                            <Ionicons name="chevron-down" size={16} />
                          </HStack>
                        </SelectTrigger>

                        <SelectPortal>
                          <SelectBackdrop />
                          <SelectContent borderRadius="$2xl" px="$3" py="$3">
                            <SelectDragIndicatorWrapper>
                              <SelectDragIndicator />
                            </SelectDragIndicatorWrapper>

                            <SelectItem
                              label="male"
                              value="male"
                              borderRadius="$xl"
                              mb="$2"
                              px="$4"
                              py="$3"
                            />
                            <SelectItem
                              label="female"
                              value="female"
                              borderRadius="$xl"
                              px="$4"
                              py="$3"
                            />
                          </SelectContent>
                        </SelectPortal>
                      </Select>

                      {!!errors.sex && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.sex}
                        </Text>
                      )}
                    </Box>
                  </HStack>

                  <Box>
                    <Label>Gender identity (optional)</Label>
                    <Input borderRadius="$xl">
                      <InputField
                        placeholder="Optional"
                        value={genderIdentity}
                        onChangeText={setGenderIdentity}
                        autoCapitalize="words"
                      />
                    </Input>
                  </Box>

                  <Divider my="$1" />

                  <HStack space="md">
                    <Box flex={1}>
                      <Label required>Height (inches)</Label>
                      <Input borderRadius="$xl" isInvalid={!!errors.heightIn}>
                        <InputField
                          placeholder="70.50"
                          value={heightIn}
                          onChangeText={(t) =>
                            setHeightIn(t.replace(/[^0-9.]/g, ""))
                          }
                          keyboardType="numbers-and-punctuation"
                          onBlur={() => {
                            if (heightIn && isValidHeightIn(heightIn)) {
                              setHeightIn(normalizeTwoDecimals(heightIn));
                            }
                          }}
                        />
                      </Input>
                      {!!errors.heightIn && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.heightIn}
                        </Text>
                      )}
                    </Box>

                    <Box flex={1}>
                      <Label required>Weight (lbs)</Label>
                      <Input borderRadius="$xl" isInvalid={!!errors.weightLbs}>
                        <InputField
                          placeholder="170.25"
                          value={weightLbs}
                          onChangeText={(t) =>
                            setWeightLbs(t.replace(/[^0-9.]/g, ""))
                          }
                          keyboardType="numbers-and-punctuation"
                          onBlur={() => {
                            if (weightLbs && isValidWeightLbs(weightLbs)) {
                              setWeightLbs(normalizeTwoDecimals(weightLbs));
                            }
                          }}
                        />
                      </Input>
                      {!!errors.weightLbs && (
                        <Text mt="$1" color="$error600" fontSize="$sm">
                          {errors.weightLbs}
                        </Text>
                      )}
                    </Box>
                  </HStack>

                  <Button
                    mt="$2"
                    size="lg"
                    borderRadius="$xl"
                    onPress={submit}
                    isDisabled={!isValid}
                  >
                    <ButtonText>Create account</ButtonText>
                  </Button>

                  {!isValid && (
                    <Text color="$text500" fontSize="$sm">
                      Please fill out all required fields.
                    </Text>
                  )}
                </VStack>
              </Box>
            </Box>
          </Center>
        </ScrollView>
      </KeyboardAvoidingView>
    </Box>
  );
}
