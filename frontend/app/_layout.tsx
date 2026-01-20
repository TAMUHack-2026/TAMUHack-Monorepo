import React from "react";
import { Stack } from "expo-router";
import { GluestackUIProvider } from "@gluestack-ui/themed";
import { config } from "@gluestack-ui/config";
import { AppStateProvider } from "../src/state/AppState";

export default function RootLayout() {
  return (
    <GluestackUIProvider config={config}>
      <AppStateProvider>
        <Stack screenOptions={{ headerShown: false }}>
          {/* index (Login) */}
          <Stack.Screen name="index" />
          {/* Dashboard */}
          <Stack.Screen name="dashboard" />
          {/* Profile (modal-ish screen) */}
          <Stack.Screen
            name="profile"
            options={{
              presentation: "modal",
              headerShown: false,
            }}
          />
        </Stack>
      </AppStateProvider>
    </GluestackUIProvider>
  );
}


