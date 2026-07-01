//
// Convusic — popup (manual conversion)
//

document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("title").textContent = i18n("popup_title");

    const settings = document.getElementById("settings-button");
    settings.textContent = i18n("settings_button_description");
    settings.addEventListener("click", openSettings);

    configure();
});

async function configure() {
    const subtitle = document.getElementById("subtitle");
    const openButton = document.getElementById("open-button");

    const tab = await activeTab();
    const response = await browser.runtime.sendMessage({ event: "service" });
    const service = response && response.service;

    if (service) {
        subtitle.textContent = i18n("service_active_description", service);
        openButton.textContent = i18n("open_button_description", service);
    } else {
        subtitle.textContent = i18n("no_service_description");
        openButton.textContent = i18n("open_button_generic");
    }

    if (tab && isMusicUrl(tab.url)) {
        openButton.addEventListener("click", () => convert(tab));
    } else {
        openButton.disabled = true;
    }
}

async function convert(tab) {
    const openButton = document.getElementById("open-button");
    openButton.disabled = true;

    const result = await browser.runtime.sendMessage({ event: "convert", url: tab.url });
    if (result && result.message === "success" && result.url) {
        await browser.tabs.update(tab.id, { url: result.url });
        window.close();
    } else {
        document.getElementById("subtitle").textContent =
            (result && result.description) || i18n("banner_failure");
        openButton.disabled = false;
    }
}

async function openSettings() {
    const tab = await activeTab();
    if (tab) {
        await browser.tabs.update(tab.id, { url: "convusic://settings" });
    }
    window.close();
}

async function activeTab() {
    const tabs = await browser.tabs.query({ active: true, currentWindow: true });
    return tabs && tabs[0];
}

function isMusicUrl(url) {
    if (!url) {
        return false;
    }
    return [
        "open.spotify.com",
        "music.apple.com",
        "music.youtube.com",
        "tidal.com",
        "pandora.com",
        "music.amazon.com",
        "deezer.com",
    ].some((host) => url.includes(host));
}

function i18n(key, ...substitutions) {
    return browser.i18n.getMessage(key, substitutions);
}
