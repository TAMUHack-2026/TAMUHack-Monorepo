import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Box,
  Button,
  ButtonText,
  Heading,
  HStack,
  Input,
  InputField,
  Text,
  VStack,
} from "@gluestack-ui/themed";
import { SexValue, useAppState } from "../state/AppState";

export default function ProfileScreen() {
  const { profile, setProfile, isProfileComplete, clearProfile } = useAppState();
  const navigate = useNavigate();

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
    navigate(-1);
  }

  function clearAll() {
    clearProfile();
    setHeight("");
    setWeight("");
    setAge("");
    setSex("");
  }

  return (
    <Box style={{ flex: 1, display: "flex", flexDirection: "column" }} bg="$background0" px={20} pt={12}>
      <HStack alignItems="center" justifyContent="space-between" pb={16}>
        <HStack alignItems="center" space="md">
          <button
            onClick={() => navigate(-1)}
            style={{
              padding: 8,
              background: "none",
              border: "none",
              cursor: "pointer",
            }}
          >
            ✕
          </button>
          <Heading size="lg">Personal Info</Heading>
        </HStack>

        <Text color={isProfileComplete ? "$success700" : "$error600"}>
          {isProfileComplete ? "Complete" : "Incomplete"}
        </Text>
      </HStack>

      <VStack space="md" style={{ overflowY: "auto", flex: 1 }}>
        <Input borderRadius="$xl">
          <InputField
            placeholder="Height (e.g., 170 cm)"
            value={height}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setHeight(e.target.value)}
            type="text"
          />
        </Input>

        <Input borderRadius="$xl">
          <InputField
            placeholder="Weight (e.g., 70 kg)"
            value={weight}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setWeight(e.target.value)}
            type="text"
          />
        </Input>

        <Input borderRadius="$xl">
          <InputField
            placeholder="Age"
            value={age}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setAge(e.target.value)}
            type="number"
          />
        </Input>

        {/* Sex picker */}
        <Box
          style={{ border: "1px solid", borderColor: "$border200" }}
          borderRadius="$2xl"
          p={12}
        >
          <Text mb={8} color="$text600">
            Sex
          </Text>

          <HStack space="sm" style={{ flexWrap: "wrap" }}>
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

        <VStack space="sm" mt={8}>
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
