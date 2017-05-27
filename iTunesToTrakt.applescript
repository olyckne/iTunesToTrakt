//#!/usr/bin/env osascript -l JavaScript

function fetch(url, data, headers) {
    dataString = "";
    if (data) {
        dataString = JSON.stringify(data);
        dataString = `-H "Content-Type: application/json" -X POST -d '${dataString}'`;
    }
    headersString = "";
    if (headers) {
        Object.keys(headers).forEach(key => {
            headersString += `-H '${key}: ${headers[key]}' `;
        });
    }
    cmd = `curl ${headersString} ${dataString} ${url}`;
    console.log(cmd);
    response = App.doShellScript(cmd);

    return response;
}

function loadConfig(path) {
    return JSON.parse($.NSString.stringWithContentsOfFile(path + "/.env").js);
}

function loadToken(path) {
    try {
        return JSON.parse($.NSString.stringWithContentsOfFile(path + "/.trakt").js);
    } catch(e) {
        return "";
    }
}

function authorize() {
    const authUrl = `${trakt.authorize}?response_type=code&client_id=${config.client_id}&redirect_uri=${config.redirect_uri}`;
    /*Safari = Application("Safari");
    window = Safari.windows[0];
    tab = Safari.Tab({url:authUrl});
    window.tabs.push(tab);
    window.currentTab = tab;*/

    answer = App.displayDialog(`Open ${authUrl} and enter pin code here:`, {
        defaultAnswer: ''
    });
    const pin = answer.textReturned;

    return pin;
}

function getToken() {
    pin = authorize();

    tokenData = {
        "code": pin,
        client_id: config.client_id,
        client_secret: config.client_secret,
        redirect_uri: config.redirect_uri,
        grant_type: "authorization_code",
    };

    response = fetch(`${trakt.base}${trakt.token}`, tokenData);
    saveToken(response);

    return JSON.parse(response);
}

function saveToken(token) {
    $.NSString.alloc.initWithUTF8String(token).writeToFileAtomically(path + "/.trakt", true);
}

function refreshToken(token) {
    const expiresAt = new Date((token.created_at+token.expires_in)*1000);
    if (new Date() > expiresAt) {
        console.log("Refreshing trakt token...");
        response = fetch(trakt.base+trakt.token, {
            "refresh_token": token.refresh_token,
            "client_id": config.client_id,
            "client_secret": config.client_secret,
            "redirect_uri": config.redirect_uri,
            "grant_type": "refresh_token",
        });
        token = response;
        saveToken(response);
    }
    return token;
}

function getAuthHeaders() {
    return {
        "Authorization": `Bearer ${token.access_token}`,
        "trakt-api-version": 2,
        "trakt-api-key": config.client_id,
    };
}

function sync(data) {
    return fetch(trakt.base+trakt.sync, data, getAuthHeaders());
}

App = Application.currentApplication();
App.includeStandardAdditions = true;
config = {};
const trakt = {
    "base": "https://api.trakt.tv/",
    "authorize": "https://trakt.tv/oauth/authorize",
    "token": "oauth/token",
    "sync": "sync/history",
};
function run(argv) {
    scriptPath = App.pathTo(this);
    scriptDir = $.NSString.alloc.initWithUTF8String(scriptPath).stringByDeletingLastPathComponent.js;
    path = scriptDir;

    config = loadConfig(path);
    token = loadToken(path);

    if (!token) {
        token = getToken();
    }

    token = refreshToken(token);

    const date = new Date();
    date.setHours(date.getHours() - config.interval);
    const tracks = Application('iTunes').playlists()
            .filter(item => item.specialKind() === 'TV Shows')
            .map(item => item.tracks())
            .reduce((a, b) => a.concat(b))
            .filter(item => item.playedDate() >= date);

    if (!tracks.length) {
        console.log("No TV Shows watched");
        return;
    }
    watched = tracks.map(item => {
        console.log(`${item.artist()} - Season ${item.seasonNumber()} Episode ${item.episodeNumber()} @ ${item.playedDate()}`);
        return {
            "title": item.artist(),
            "year": item.year(),
            "seasons": [{
                "number": item.seasonNumber(),
                "episodes": [
                    {
                        "watched_at": item.playedDate(),
                        "number": item.episodeNumber()
                    }
                ],
            }],
        };
    });

    data = {"shows": watched};
    response = sync(data);
    console.log(response);
}

