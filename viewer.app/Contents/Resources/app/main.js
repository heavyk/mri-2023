const {app, BrowserWindow} = require('electron')
const path = require('path')
const url = require('url')
const electron = require('electron')
const ipcMain = electron.ipcMain

let win

function createWindow () {
    // Create the browser window.
    win = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            preload: path.join(__dirname, '/prompt.js')
        }
    });

    // and load the index.html of the app.
    win.loadURL(url.format({
        pathname: path.join(__dirname, 'VIEW_IMAGES.html'),
        protocol: 'file:',
        slashes: true
    }));

    //win.webContents.openDevTools()

    win.on('closed', () => {
        win = null
    })

    // https://github.com/electron/electron/issues/472#issuecomment-202686377
    var promptResponse
    ipcMain.on('prompt', function(eventRet, arg) {
        promptResponse = null
        var promptWindow = new BrowserWindow({
            width: 200,
            height: 100,
            show: false,
            resizable: false,
            movable: false,
            alwaysOnTop: true,
            frame: false
        })
        arg.val = arg.val || ''
        const promptHtml = '<label for="val">' + arg.title + '</label>\
    <input id="val" value="' + arg.val + '" autofocus />\
    <button onclick="require(\'electron\').ipcRenderer.send(\'prompt-response\', document.getElementById(\'val\').value);window.close()">Ok</button>\
    <button onclick="window.close()">Cancel</button>\
    <style>body {font-family: sans-serif;} button {float:right; margin-left: 10px;} label,input {margin-bottom: 10px; width: 100%; display:block;}</style>'
        promptWindow.loadURL('data:text/html,' + promptHtml)
        promptWindow.show()
        promptWindow.on('closed', function() {
            eventRet.returnValue = promptResponse
            promptWindow = null
        })
    })
    ipcMain.on('prompt-response', function(event, arg) {
        if (arg === ''){ arg = null }
        promptResponse = arg
    })
}

app.on('ready', createWindow)

app.on('window-all-closed', () => {
    app.quit()
})

app.on('activate', () => {
    if (win === null) {
    createWindow()
}
})
