# Spirometer Electron App

An Electron desktop application for spirometer data collection with Bluetooth Classic support.

## Features

- Electron-based desktop application
- Bluetooth Classic connectivity using `bluetooth-serial-port`
- React-based UI with Gluestack UI components
- React Router for navigation
- TypeScript support

## Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Bluetooth adapter (for Bluetooth Classic functionality)

### Platform-Specific Requirements

**Linux:**
```bash
sudo apt-get install build-essential libbluetooth-dev
```

**Windows:**
- Visual Studio with C++ tools
- Python 2.x (for native module compilation)

**macOS:**
- ⚠️ **Note:** macOS support was dropped in `bluetooth-serial-port` v3.0.0
- If you need macOS support, you'll need to use v2.2.7 or find an alternative solution

## Installation

1. Install dependencies:

```bash
npm install
```

## Development

To run the app in development mode:

```bash
npm run dev
```

This will:
- Start the Vite dev server on `http://localhost:3000`
- Launch Electron when the dev server is ready
- Open DevTools automatically

Alternatively, you can run them separately:

```bash
# Terminal 1: Start Vite dev server
npm run dev:react

# Terminal 2: Start Electron (after Vite is running)
npm start
```

## Building

Build the React app for production:

```bash
npm run build
```

Build the Electron app (requires `electron-builder`):

```bash
npm run build:electron
```

## Project Structure

```
frontend/
├── main.js              # Electron main process
├── preload.js           # Electron preload script (IPC bridge)
├── index.html           # HTML entry point
├── vite.config.ts       # Vite configuration
├── src/
│   ├── main.tsx         # React entry point
│   ├── App.tsx          # Main app component with routing
│   ├── screens/         # Screen components
│   │   ├── LoginScreen.tsx
│   │   ├── DashboardScreen.tsx
│   │   └── ProfileScreen.tsx
│   ├── components/      # Reusable components
│   │   └── RecordingPanel.tsx
│   ├── state/           # State management
│   │   └── AppState.tsx
│   └── services/        # Services
│       └── bluetooth.ts  # Bluetooth service
└── package.json
```

## Bluetooth Classic Support

The app includes Bluetooth Classic support via the `bluetooth-serial-port` package. The Bluetooth service is available through the Electron IPC bridge:

```typescript
import { bluetoothService } from './services/bluetooth';

// Scan for devices
const devices = await bluetoothService.scanDevices();

// Connect to a device
await bluetoothService.connect(deviceAddress);

// Write data
await bluetoothService.write('Hello, device!');

// Listen for data
bluetoothService.onData((data) => {
  console.log('Received:', data);
});

// Disconnect
await bluetoothService.disconnect();
```

## Technologies Used

- **Electron**: Desktop app framework
- **React**: UI library
- **React Router**: Client-side routing
- **Vite**: Build tool and dev server
- **TypeScript**: Type safety
- **Gluestack UI**: UI component library
- **Tailwind CSS**: Styling
- **bluetooth-serial-port**: Bluetooth Classic communication (v3.0.2)
  - ⚠️ **Note:** This package is deprecated and has no macOS support in v3.0.0+
  - For macOS, consider using v2.2.7 or alternative solutions

## Notes

- The app uses Electron's context isolation for security
- Bluetooth functionality is handled in the main process and exposed via IPC
- The preload script provides a secure bridge between renderer and main process
