const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  bluetooth: {
    inquiry: () => ipcRenderer.invoke('bluetooth:inquiry'),
    findSerialPortChannel: (address) => ipcRenderer.invoke('bluetooth:findSerialPortChannel', address),
    connect: (address, channel) => ipcRenderer.invoke('bluetooth:connect', address, channel),
    disconnect: () => ipcRenderer.invoke('bluetooth:disconnect'),
    write: (data) => ipcRenderer.invoke('bluetooth:write', data),
    isOpen: () => ipcRenderer.invoke('bluetooth:isOpen'),
    onData: (callback) => {
      ipcRenderer.on('bluetooth:data', (event, data) => callback(data));
    },
    onClosed: (callback) => {
      ipcRenderer.on('bluetooth:closed', () => callback());
    },
    onFailure: (callback) => {
      ipcRenderer.on('bluetooth:failure', (event, error) => callback(error));
    },
    removeAllListeners: () => {
      ipcRenderer.removeAllListeners('bluetooth:data');
      ipcRenderer.removeAllListeners('bluetooth:closed');
      ipcRenderer.removeAllListeners('bluetooth:failure');
    },
  },
});
