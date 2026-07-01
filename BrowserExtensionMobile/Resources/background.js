//
// Convusic — background message router
//
// Bridges page/popup messages to the native handler (SafariWebExtensionHandler).
// Content script & popup speak {event}; this translates to the native
// {message} contract and normalizes replies back.
//

const NATIVE_APP = "application.id";

browser.runtime.onMessage.addListener((request, sender, _sendResponse) => {
    const url = request.url || (sender.tab && sender.tab.url);

    switch (request.event) {
        case "request":
            // Eligibility check before we show any UI.
            return browser.runtime
                .sendNativeMessage(NATIVE_APP, { message: "request", url })
                .then((response) =>
                    response && response.message === "pass"
                        ? { message: "convert" }
                        : { message: "none" }
                )
                .catch(() => ({ message: "none" }));

        case "convert":
            // Resolve the link and (native side) record it to history.
            return browser.runtime
                .sendNativeMessage(NATIVE_APP, { message: "transform", url })
                .then((response) => {
                    if (response && response.url) {
                        return { message: "success", url: response.url };
                    }
                    return {
                        message: "failure",
                        error: (response && response.error) || "failure",
                        description: response && response.description,
                    };
                })
                .catch((error) => ({
                    message: "failure",
                    error: "failure",
                    description: String(error),
                }));

        case "service":
            return browser.runtime
                .sendNativeMessage(NATIVE_APP, { message: "service" })
                .then((response) => ({ service: response && response.service }))
                .catch(() => ({ service: null }));

        default:
            return undefined;
    }
});
