// src/state/AppState.tsx
import React, { createContext, useContext, useMemo, useState } from "react";

export type SexValue = "Male" | "Female" | "";

export type ProfileInfo = {
  height: string;
  weight: string;
  age: string;
  sex: SexValue;
};

export type RecordingRow = {
  id: string;
  timestamp: string;
  data: "N/A";
};

type AppState = {
  profile: ProfileInfo;
  setProfile: (p: ProfileInfo) => void;

  rows: RecordingRow[];
  addRow: () => void;

  clearProfile: () => void;
};

const defaultProfile: ProfileInfo = {
  height: "",
  weight: "",
  age: "",
  sex: "",
};

const Ctx = createContext<AppState | null>(null);

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [profile, setProfile] = useState<ProfileInfo>(defaultProfile);
  const [rows, setRows] = useState<RecordingRow[]>([]);

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

  const value = useMemo(
    () => ({
      profile,
      setProfile,
      rows,
      addRow,
      clearProfile,
    }),
    [profile, rows]
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAppState() {
  const v = useContext(Ctx);
  if (!v) throw new Error("useAppState must be used within AppStateProvider");
  return v;
}
