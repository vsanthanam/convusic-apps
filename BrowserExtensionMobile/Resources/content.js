//
// Convusic — content script (auto-convert)
//
// On load of a supported music page, asks the native handler whether the page
// is eligible (a known service other than the user's preferred one). If so,
// shows an in-page banner, resolves the link, and redirects this tab to the
// equivalent page on the preferred service.
//

(function () {
    const here = location.href;

    browser.runtime.sendMessage({ event: "request", url: here }).then((response) => {
        if (!response || response.message !== "convert") {
            return;
        }
        showBanner("🔊 " + i18n("banner_loading"));
        // Brief pause so the banner is actually visible before a fast resolve
        // redirects the page out from under it.
        setTimeout(() => {
            browser.runtime.sendMessage({ event: "convert", url: here }).then((result) => {
                if (result && result.message === "success" && result.url) {
                    hideBanner();
                    window.stop();
                    window.location.href = result.url;
                } else {
                    const description = (result && result.description) || i18n("banner_failure");
                    showBanner("⚠️ " + description);
                }
            });
        }, 250);
    });

    function i18n(key) {
        return browser.i18n.getMessage(key);
    }

    function showBanner(message) {
        hideBanner();

        const link = document.createElement("link");
        link.href = browser.runtime.getURL("banner.css");
        link.type = "text/css";
        link.rel = "stylesheet";
        document.getElementsByTagName("head")[0].appendChild(link);

        const banner = document.createElement("div");
        banner.className = "convusic-banner";
        banner.id = "convusic-banner";

        const text = document.createElement("div");
        text.className = "convusic-banner-text";
        text.id = "convusic-banner-message";
        text.textContent = message;

        banner.appendChild(text);
        document.body.insertBefore(banner, document.body.firstChild);
    }

    function hideBanner() {
        const existing = document.getElementById("convusic-banner");
        if (existing) {
            existing.parentNode.removeChild(existing);
        }
    }
})();
