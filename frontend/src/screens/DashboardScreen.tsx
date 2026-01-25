import React, { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Box,
  Button,
  ButtonText,
  HStack,
  Heading,
  Text,
  VStack,
} from "@gluestack-ui/themed";
import RecordingPanel from "../components/RecordingPanel";
import { useAppState } from "../state/AppState";

export default function DashboardScreen() {
  const { rows, addRow, isProfileComplete } = useAppState();
  const [recordingVisible, setRecordingVisible] = useState(false);
  const navigate = useNavigate();

  const badgeVisible = useMemo(() => !isProfileComplete, [isProfileComplete]);

  function startRecording() {
    if (!isProfileComplete) {
      alert("Missing Info", "Please enter your personal information first.");
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
    <Box style={{ flex: 1, display: "flex", flexDirection: "column" }} bg="$background0">
      {/* Top bar */}
      <HStack
        px={20}
        py={16}
        alignItems="center"
        justifyContent="space-between"
        style={{ borderBottom: "1px solid", borderBottomColor: "$border200" }}
      >
        <Heading size="lg">Personal Dashboard</Heading>

        <button
          onClick={() => navigate("/profile")}
          style={{
            padding: 8,
            background: "none",
            border: "none",
            cursor: "pointer",
            position: "relative",
          }}
        >
          <Box>
            <span style={{ fontSize: 28 }}>👤</span>
            {badgeVisible && (
              <Box
                position="absolute"
                top={-2}
                right={-2}
                w={12}
                h={12}
                borderRadius={999}
                bg="$error600"
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                <Text fontSize="$xs" color="$text0" style={{ lineHeight: 12 }}>
                  !
                </Text>
              </Box>
            )}
          </Box>
        </button>
      </HStack>

      <div style={{ padding: 20, paddingBottom: 40, overflowY: "auto", flex: 1 }}>
        <VStack space="lg">
          {/* Record button */}
          <Button
            borderRadius="$2xl"
            size="xl"
            py={24}
            onPress={startRecording}
          >
            <ButtonText fontSize="$xl">Record</ButtonText>
          </Button>

          {/* Table */}
          <Box
            style={{ border: "1px solid", borderColor: "$border200" }}
            borderRadius="$2xl"
            overflow="hidden"
          >
            {/* Header row */}
            <HStack
              px={16}
              py={12}
              bg="$background50"
              style={{ borderBottom: "1px solid", borderBottomColor: "$border200" }}
              justifyContent="space-between"
            >
              <Text fontWeight="$bold">Timestamp</Text>
              <Text fontWeight="$bold">Data</Text>
            </HStack>

            {rows.length === 0 ? (
              <Box px={16} py={24}>
                <Text color="$text500">
                  No recordings yet. Tap Record to add one.
                </Text>
              </Box>
            ) : (
              rows.map((r) => (
                <HStack
                  key={r.id}
                  px={16}
                  py={16}
                  style={{ borderBottom: "1px solid", borderBottomColor: "$border100" }}
                  justifyContent="space-between"
                >
                  <Text style={{ flex: 1, paddingRight: 16 }}>
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
      </div>

      {/* Slide-down recording panel */}
      <RecordingPanel
        visible={recordingVisible}
        onCancel={cancelRecording}
        onFinished={finishRecording}
      />
    </Box>
  );
}
