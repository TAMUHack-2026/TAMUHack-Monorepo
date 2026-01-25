// src/state/AppState.tsx
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { ApiClient } from "../api/client";

export type SexValue = "Male" | "Female" | "";

export type ProfileInfo = {
  email: string;
  firstName: string; // Added (was missing)
  lastName: string;  // Added (was missing)
  height: string;
  weight: string;
  age: string;
  sex: SexValue;
  genderIdentity: string; // Added
};

export type RecordingRow = {
  id: string;
  timestamp: string;
  data: "N/A";
};

type AppState = {
  profile: ProfileInfo;
  setProfile: (p: ProfileInfo) => void;
  saveProfile: (p: ProfileInfo) => Promise<boolean>;

  rows: RecordingRow[];
  addRow: () => void;

  clearProfile: () => void;
  isConnected: boolean;
};

const defaultProfile: ProfileInfo = {
  email: "",
  firstName: "",
  lastName: "",
  height: "",
  weight: "",
  age: "",
  sex: "",
  genderIdentity: "",
};

const Ctx = createContext<AppState | null>(null);

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [profile, setProfile] = useState<ProfileInfo>(defaultProfile);
  const [rows, setRows] = useState<RecordingRow[]>([]);
  const [isConnected, setIsConnected] = useState(false);

  // Check connection on mount
  useEffect(() => {
    ApiClient.ping().then(setIsConnected);
  }, []);

  function addRow() {
    const now = new Date();
    const timestamp = now.toLocaleString();
    setRows((prev) => [
      {
        id: String(now.getTime()) + "-" + Math.random().toString(16).slice(2),
        timestamp,
        data: "N/A",
      },
      ...prev,
    ]);
  }

  function clearProfile() {
    setProfile(defaultProfile);
  }

  // Wrapper to save to backend
  async function saveProfile(newProfile: ProfileInfo): Promise<boolean> {
    setProfile(newProfile);
    if (!newProfile.email) return true; // Local save only if no email

    // Try to update first
    try {
      return await ApiClient.updateUser(newProfile.email, newProfile);
    } catch (e) {
      // If update failed (likely 404), try to create
      console.log("Update failed, trying to create user...");
      return await ApiClient.createUser(newProfile.email, newProfile);
    }
  }

  // Try to load profile if email is set (or maybe we need a separate "login" action?)
  // For now, if the user manually sets their email, we could try to fetch their data?
  // Let's stick to simple "save" pushes for now. 
  // Retrieving data on email entry would be good UX but might be complex to implement right now.

  const value = useMemo(
    () => ({
      profile,
      setProfile,
      saveProfile,
      rows,
      addRow,
      clearProfile,
      isConnected,
    }),
    [profile, rows, isConnected]
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAppState() {
  const v = useContext(Ctx);
  if (!v) throw new Error("useAppState must be used within AppStateProvider");
  return v;
}
