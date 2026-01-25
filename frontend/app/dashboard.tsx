import React, { useState } from "react";
import {
  Box,
  Button,
  ButtonText,
  HStack,
  Heading,
  ScrollView,
  Text,
  VStack,
} from "@gluestack-ui/themed";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import RecordingPanel from "../src/components/RecordingPanel";
import { useAppState } from "../src/state/AppState";
import AsyncStorage from "@react-native-async-storage/async-storage";

export default function DashboardScreen() {
  const { rows, addRow } = useAppState();
  const [recordingVisible, setRecordingVisible] = useState(false);
  const insets = useSafeAreaInsets();

  function startRecording() {
    AsyncStorage.clear();
    setRecordingVisible(true);
  }

  function cancelRecording() {
    setRecordingVisible(false);
  }

  function finishRecording() {
    setRecordingVisible(false);
    addRow();
  }

  function onPairPress() {
    // Placeholder for Bluetooth pairing flow (to be implemented later)
    console.log("PAIR pressed (placeholder)");
  }

  return (
    <Box flex={1} bg="$background0">
      {/* Top bar (profile removed) */}
      <HStack
        px="$5"
        pt={insets.top + 12}
        pb="$4"
        alignItems="center"
        justifyContent="space-between"
        borderBottomWidth={1}
        borderBottomColor="$border200"
      >
        <Heading size="lg">Personal Dashboard</Heading>
      </HStack>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 40 }}>
        <VStack space="lg">
          {/* Record button */}
          <Button borderRadius="$2xl" size="xl" py="$6" onPress={startRecording}>
            <ButtonText fontSize="$xl">Record</ButtonText>
          </Button>

          {/* Pair button (placeholder) */}
          <Button
            borderRadius="$2xl"
            size="lg"
            variant="outline"
            onPress={onPairPress}
          >
            <ButtonText>Pair</ButtonText>
          </Button>

          {/* Table */}
          <Box
            borderWidth={1}
            borderColor="$border200"
            borderRadius="$2xl"
            overflow="hidden"
          >
            {/* Header row */}
            <HStack
              px="$4"
              py="$3"
              bg="$background50"
              borderBottomWidth={1}
              borderBottomColor="$border200"
              justifyContent="space-between"
            >
              <Text fontWeight="$bold">Timestamp</Text>
              <Text fontWeight="$bold">Data</Text>
            </HStack>

            {rows.length === 0 ? (
              <Box px="$4" py="$6">
                <Text color="$text500">
                  No recordings yet. Tap Record to add one.
                </Text>
              </Box>
            ) : (
              rows.map((r) => (
                <HStack
                  key={r.id}
                  px="$4"
                  py="$4"
                  borderBottomWidth={1}
                  borderBottomColor="$border100"
                  justifyContent="space-between"
                >
                  <Text flex={1} pr="$4">
                    {r.timestamp}
                  </Text>
                  <Text>{r.data}</Text>
                </HStack>
              ))
            )}
          </Box>

          <Text color="$text500">
            All spirometer values are displayed as N/A (frontend-only MVP).
          </Text>
        </VStack>
      </ScrollView>

      {/* Slide-down recording panel */}
      <RecordingPanel
        visible={recordingVisible}
        onCancel={cancelRecording}
        onFinished={finishRecording}
      />
    </Box>
  );
}
