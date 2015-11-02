chrome.runtime.onConnect.addListener(function(messagePort) {
    messagePort.onMessage.addListener(function(message){
        console.log(message)
        messagePort.postMessage(message)
    })
})
