import React, { useState } from "react";
import { router } from "expo-router";
import {
  Box,
  Button,
  ButtonText,
  Center,
  Heading,
  Input,
  InputField,
  Text,
  VStack,
} from "@gluestack-ui/themed";

export default function LoginScreen() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  return (
    <Center flex={1} px="$6">
      <Box w="$full" maxWidth={420} p="$6" borderRadius="$2xl" bg="$background0">
        <VStack space="lg">
          <Heading size="xl">Spirometer</Heading>
          <Text color="$text500">
            Frontend MVP (no backend). Login just navigates.
          </Text>

          <VStack space="md">
            <Input borderRadius="$xl">
              <InputField
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
              />
            </Input>

            <Input borderRadius="$xl">
              <InputField
                placeholder="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
              />
            </Input>

            <Button
              borderRadius="$xl"
              onPress={() => router.replace("/dashboard" as any)}
            >
              <ButtonText>Login</ButtonText>
            </Button>
          </VStack>
        </VStack>
      </Box>
    </Center>
  );
}



