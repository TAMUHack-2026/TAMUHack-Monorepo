// Bluetooth service for Electron app
// Uses the electronAPI exposed via preload.js

declare global {
  interface Window {
    electronAPI?: {
      bluetooth: {
        inquiry: () => Promise<Array<{ address: string; name: string }>>;
        findSerialPortChannel: (address: string) => Promise<number>;
        connect: (address: string, channel: number) => Promise<boolean>;
        disconnect: () => Promise<boolean>;
        write: (data: string) => Promise<number>;
        isOpen: () => Promise<boolean>;
        onData: (callback: (data: string) => void) => void;
        onClosed: (callback: () => void) => void;
        onFailure: (callback: (error: string) => void) => void;
        removeAllListeners: () => void;
      };
    };
  }
}

export interface BluetoothDevice {
  address: string;
  name: string;
}

export class BluetoothService {
  private static instance: BluetoothService;
  private isConnected: boolean = false;
  private currentAddress: string | null = null;
  private dataCallback: ((data: string) => void) | null = null;

  private constructor() {
    // Set up event listeners if electronAPI is available
    if (typeof window !== 'undefined' && window.electronAPI) {
      window.electronAPI.bluetooth.onClosed(() => {
        this.isConnected = false;
        this.currentAddress = null;
      });

      window.electronAPI.bluetooth.onFailure((error) => {
        console.error('Bluetooth connection failure:', error);
        this.isConnected = false;
        this.currentAddress = null;
      });
    }
  }

  static getInstance(): BluetoothService {
    if (!BluetoothService.instance) {
      BluetoothService.instance = new BluetoothService();
    }
    return BluetoothService.instance;
  }

  async scanDevices(): Promise<BluetoothDevice[]> {
    if (!window.electronAPI) {
      throw new Error('Electron API not available. Make sure you are running in Electron.');
    }
    return await window.electronAPI.bluetooth.inquiry();
  }

  async connect(address: string): Promise<boolean> {
    if (!window.electronAPI) {
      throw new Error('Electron API not available. Make sure you are running in Electron.');
    }

    try {
      const channel = await window.electronAPI.bluetooth.findSerialPortChannel(address);
      const connected = await window.electronAPI.bluetooth.connect(address, channel);
      
      if (connected) {
        this.isConnected = true;
        this.currentAddress = address;
      }
      
      return connected;
    } catch (error) {
      console.error('Failed to connect:', error);
      throw error;
    }
  }

  async disconnect(): Promise<boolean> {
    if (!window.electronAPI) {
      throw new Error('Electron API not available. Make sure you are running in Electron.');
    }

    try {
      if (this.dataCallback) {
        window.electronAPI.bluetooth.removeAllListeners();
        this.dataCallback = null;
      }
      const disconnected = await window.electronAPI.bluetooth.disconnect();
      
      if (disconnected) {
        this.isConnected = false;
        this.currentAddress = null;
      }
      
      return disconnected;
    } catch (error) {
      console.error('Failed to disconnect:', error);
      throw error;
    }
  }

  async write(data: string): Promise<number> {
    if (!window.electronAPI) {
      throw new Error('Electron API not available. Make sure you are running in Electron.');
    }

    if (!this.isConnected) {
      const isOpen = await window.electronAPI.bluetooth.isOpen();
      if (!isOpen) {
        throw new Error('Not connected to a device');
      }
      this.isConnected = true;
    }

    return await window.electronAPI.bluetooth.write(data);
  }

  onData(callback: (data: string) => void): void {
    if (!window.electronAPI) {
      throw new Error('Electron API not available. Make sure you are running in Electron.');
    }

    if (this.dataCallback) {
      window.electronAPI.bluetooth.removeAllListeners();
    }

    this.dataCallback = callback;
    window.electronAPI.bluetooth.onData(callback);
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }

  getCurrentAddress(): string | null {
    return this.currentAddress;
  }

  async checkConnectionStatus(): Promise<boolean> {
    if (!window.electronAPI) {
      return false;
    }
    this.isConnected = await window.electronAPI.bluetooth.isOpen();
    return this.isConnected;
  }
}

export const bluetoothService = BluetoothService.getInstance();
