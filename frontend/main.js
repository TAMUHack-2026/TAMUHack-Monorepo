const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const btSerial = require('bluetooth-serial-port');

let mainWindow;
let bluetoothAdapter = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  // Load the app
  const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged;
  if (isDev) {
    mainWindow.loadURL('http://localhost:3000');
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, 'dist/index.html'));
  }
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// Bluetooth IPC handlers
ipcMain.handle('bluetooth:inquiry', async () => {
  return new Promise((resolve, reject) => {
    if (!bluetoothAdapter) {
      bluetoothAdapter = new btSerial.BluetoothSerialPort();
    }

    const devices = [];
    const timeout = setTimeout(() => {
      bluetoothAdapter.removeAllListeners('found');
      bluetoothAdapter.removeAllListeners('finished');
      if (devices.length === 0) {
        reject(new Error('No devices found or inquiry timeout'));
      } else {
        resolve(devices);
      }
    }, 10000); // 10 second timeout

    bluetoothAdapter.on('found', (address, name) => {
      devices.push({
        address: address,
        name: name || 'Unknown Device',
      });
    });

    bluetoothAdapter.on('finished', () => {
      clearTimeout(timeout);
      bluetoothAdapter.removeAllListeners('found');
      bluetoothAdapter.removeAllListeners('finished');
      resolve(devices);
    });

    try {
      bluetoothAdapter.inquire();
    } catch (err) {
      clearTimeout(timeout);
      bluetoothAdapter.removeAllListeners('found');
      bluetoothAdapter.removeAllListeners('finished');
      reject(err);
    }
  });
});

ipcMain.handle('bluetooth:findSerialPortChannel', async (event, address) => {
  return new Promise((resolve, reject) => {
    if (!bluetoothAdapter) {
      bluetoothAdapter = new btSerial.BluetoothSerialPort();
    }

    bluetoothAdapter.findSerialPortChannel(
      address,
      (channel) => {
        resolve(channel);
      },
      (err) => {
        reject(err || new Error('Serial port channel not found'));
      }
    );
  });
});

ipcMain.handle('bluetooth:connect', async (event, address, channel) => {
  return new Promise((resolve, reject) => {
    if (!bluetoothAdapter) {
      bluetoothAdapter = new btSerial.BluetoothSerialPort();
    }

    // Set up data listener before connecting
    bluetoothAdapter.on('data', (buffer) => {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('bluetooth:data', buffer.toString('utf-8'));
      }
    });

    bluetoothAdapter.connect(
      address,
      channel,
      () => {
        resolve(true);
      },
      (err) => {
        bluetoothAdapter.removeAllListeners('data');
        reject(err || new Error('Connection failed'));
      }
    );
  });
});

ipcMain.handle('bluetooth:disconnect', async () => {
  return new Promise((resolve) => {
    if (bluetoothAdapter) {
      bluetoothAdapter.removeAllListeners('data');
      bluetoothAdapter.removeAllListeners('closed');
      bluetoothAdapter.removeAllListeners('failure');
      bluetoothAdapter.close();
      bluetoothAdapter = null;
    }
    resolve(true);
  });
});

ipcMain.handle('bluetooth:write', async (event, data) => {
  return new Promise((resolve, reject) => {
    if (!bluetoothAdapter || !bluetoothAdapter.isOpen()) {
      reject(new Error('Not connected'));
      return;
    }

    bluetoothAdapter.write(Buffer.from(data, 'utf-8'), (err, bytesWritten) => {
      if (err) {
        reject(err);
      } else {
        resolve(bytesWritten);
      }
    });
  });
});

ipcMain.handle('bluetooth:isOpen', async () => {
  if (!bluetoothAdapter) {
    return false;
  }
  return bluetoothAdapter.isOpen();
});

// Handle connection closed/failure events
if (bluetoothAdapter) {
  bluetoothAdapter.on('closed', () => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('bluetooth:closed');
    }
  });

  bluetoothAdapter.on('failure', (err) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('bluetooth:failure', err.message);
    }
  });
}
