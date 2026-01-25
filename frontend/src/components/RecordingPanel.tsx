import React, { useEffect, useMemo, useRef, useState } from "react";
import {
  Box,
  Button,
  ButtonText,
  Center,
  Heading,
  Text,
  VStack,
} from "@gluestack-ui/themed";

type Props = {
  visible: boolean;
  onCancel: () => void;
  onFinished: () => void;
};

export default function RecordingPanel({ visible, onCancel, onFinished }: Props) {
  const [secondsLeft, setSecondsLeft] = useState<number>(5);
  const [mounted, setMounted] = useState<boolean>(visible);
  const [translateY, setTranslateY] = useState<string>("-100%");
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    if (visible) {
      setMounted(true);
      // Trigger animation after mount
      setTimeout(() => setTranslateY("0%"), 10);
    } else {
      setTranslateY("-100%");
      // Wait for animation to complete
      setTimeout(() => setMounted(false), 240);
    }
  }, [visible]);

  useEffect(() => {
    if (!visible) {
      setSecondsLeft(5);
      if (intervalRef.current) clearInterval(intervalRef.current);
      intervalRef.current = null;
      return;
    }

    setSecondsLeft(5);

    intervalRef.current = setInterval(() => {
      setSecondsLeft((s) => s - 1);
    }, 1000);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      intervalRef.current = null;
    };
  }, [visible]);

  // Auto-finish
  useEffect(() => {
    if (visible && secondsLeft <= 0) {
      if (intervalRef.current) clearInterval(intervalRef.current);
      intervalRef.current = null;
      onFinished();
    }
  }, [secondsLeft, visible, onFinished]);

  if (!mounted) return null;

  return (
    <div
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        transform: `translateY(${translateY})`,
        transition: translateY === "0%" ? "transform 280ms cubic-bezier(0.4, 0, 0.2, 1)" : "transform 240ms cubic-bezier(0.4, 0, 1, 1)",
        zIndex: 100,
        pointerEvents: visible ? "auto" : "none",
      }}
    >
      {/* Solid blue background */}
      <Box style={{ flex: 1, display: "flex", flexDirection: "column" }} bg="$primary600">
        <Center style={{ flex: 1 }}>
          <VStack space="lg" px={24} style={{ alignItems: "center" }}>
            <Heading size="xl" color="$text0" style={{ textAlign: "center" }}>
              Breathe now
            </Heading>

            <Text color="$text0" style={{ opacity: 0.9 }}>
              Blow steadily into the device
            </Text>

            <Box
              mt={16}
              borderRadius={999}
              bg="$primary700"
              w={140}
              h={140}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <Text fontSize="$6xl" color="$text0">
                {secondsLeft}
              </Text>
            </Box>

            <Button
              mt={24}
              variant="outline"
              style={{ borderColor: "$text0" }}
              onPress={onCancel}
            >
              <ButtonText color="$text0">Cancel</ButtonText>
            </Button>
          </VStack>
        </Center>
      </Box>
    </div>
  );
}
