import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
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
  const navigate = useNavigate();

  return (
    <Center style={{ flex: 1, padding: 24 }}>
      <Box w="100%" maxWidth={420} p={24} borderRadius="$2xl" bg="$background0">
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
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setUsername(e.target.value)}
                autoCapitalize="none"
              />
            </Input>

            <Input borderRadius="$xl">
              <InputField
                placeholder="Password"
                type="password"
                value={password}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
              />
            </Input>

            <Button
              borderRadius="$xl"
              onPress={() => navigate("/dashboard")}
            >
              <ButtonText>Login</ButtonText>
            </Button>
          </VStack>
        </VStack>
      </Box>
    </Center>
  );
}
