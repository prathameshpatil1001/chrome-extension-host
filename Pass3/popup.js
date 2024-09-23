chrome.storage.local.get("sessionid", function(data) {
    document.getElementById('session-id').textContent = data.sessionid || "Session ID not found";
});
