import React, { useEffect, useMemo, useRef, useState } from "react";
import { Animated, Easing, Dimensions } from "react-native";
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
  const screenH = Dimensions.get("window").height;

  const [secondsLeft, setSecondsLeft] = useState<number>(5);
  const [mounted, setMounted] = useState<boolean>(visible);

  const anim = useRef(new Animated.Value(0)).current; 
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const translateY = useMemo(
    () =>
      anim.interpolate({
        inputRange: [0, 1],
        outputRange: [-screenH, 0], 
      }),
    [anim, screenH]
  );

  useEffect(() => {
    if (visible) {
      setMounted(true);
      Animated.timing(anim, {
        toValue: 1,
        duration: 280,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(anim, {
        toValue: 0,
        duration: 240,
        easing: Easing.in(Easing.cubic),
        useNativeDriver: true,
      }).start(({ finished }) => {
        if (finished) setMounted(false); 
      });
    }
  }, [visible, anim]);

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
    <Animated.View
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        transform: [{ translateY }],
        zIndex: 100,
      }}
      pointerEvents={visible ? "auto" : "none"}
    >
      {/* Solid blue background */}
      <Box flex={1} bg="$primary600">
        <Center flex={1}>
          <VStack space="lg" px="$6" alignItems="center">
            <Heading size="xl" color="$text0" textAlign="center">
              Breathe now
            </Heading>

            <Text color="$text0" opacity={0.9}>
              Blow steadily into the device
            </Text>

            <Box
              mt="$4"
              borderRadius="$full"
              bg="$primary700"
              w={140}
              h={140}
              alignItems="center"
              justifyContent="center"
            >
              <Text fontSize="$6xl" color="$text0">
                {secondsLeft}
              </Text>
            </Box>

            <Button
              mt="$6"
              variant="outline"
              borderColor="$text0"
              onPress={onCancel}
            >
              <ButtonText color="$text0">Cancel</ButtonText>
            </Button>
          </VStack>
        </Center>
      </Box>
    </Animated.View>
  );
}


