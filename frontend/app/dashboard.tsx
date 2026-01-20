import React, { useMemo, useState } from "react";
import { Alert, Pressable } from "react-native";
import { router } from "expo-router";
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
import { Ionicons } from "@expo/vector-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import RecordingPanel from "../src/components/RecordingPanel";
import { useAppState } from "../src/state/AppState";

export default function DashboardScreen() {
  const { rows, addRow, isProfileComplete } = useAppState();
  const [recordingVisible, setRecordingVisible] = useState(false);
  const insets = useSafeAreaInsets();

  const badgeVisible = useMemo(() => !isProfileComplete, [isProfileComplete]);

  function startRecording() {
    if (!isProfileComplete) {
      Alert.alert("Missing Info", "Please enter your personal information first.");
      return;
    }
    setRecordingVisible(true);
  }

  function cancelRecording() {
    setRecordingVisible(false);
  }

  function finishRecording() {
    setRecordingVisible(false);
    addRow();
  }

  return (
    <Box flex={1} bg="$background0">
      {/* Top bar */}
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

        <Pressable
          onPress={() => router.push("/profile")}
          style={{ padding: 8 }}
          hitSlop={10}
        >
          <Box>
            <Ionicons name="person-circle-outline" size={28} />
            {badgeVisible && (
              <Box
                position="absolute"
                top={-2}
                right={-2}
                w={12}
                h={12}
                borderRadius={999}
                bg="$error600"
                alignItems="center"
                justifyContent="center"
              >
                <Text fontSize="$xs" color="$text0" lineHeight={12}>
                  !
                </Text>
              </Box>
            )}
          </Box>
        </Pressable>
      </HStack>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: 40 }}>
        <VStack space="lg">
          {/* Record button */}
          <Button
            borderRadius="$2xl"
            size="xl"
            py="$6"
            onPress={startRecording}
          >
            <ButtonText fontSize="$xl">Record</ButtonText>
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


