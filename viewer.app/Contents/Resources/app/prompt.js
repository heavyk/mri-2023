// https://github.com/electron/electron/issues/472#issuecomment-202686377
// put this preload for main-window to give it prompt()
const ipcRenderer = require('electron').ipcRenderer

window.prompt = function(title, val){
    return ipcRenderer.sendSync('prompt', {title, val})
}