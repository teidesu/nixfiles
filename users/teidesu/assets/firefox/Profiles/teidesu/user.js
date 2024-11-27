// doh
user_pref("doh-rollout.disable-heuristics", true);
user_pref("doh-rollout.doneFirstRun", true);
user_pref("doh-rollout.home-region", "RU");
user_pref("doh-rollout.uri", "https://mozilla.cloudflare-dns.com/dns-query");
user_pref("network.trr.excluded-domains", "jsr.test, stupid.fish");
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");

// personal preferences
user_pref("browser.startup.page", 3);
user_pref("font.name.monospace.x-western", "IosevkaSS05 Nerd Font");
user_pref("browser.newtab.extensionControlled", true);
user_pref("browser.translations.neverTranslateLanguages", "ru");
user_pref("browser.formfill.enable", false);
user_pref("signon.autofillForms", false);
user_pref("signon.rememberSignons", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.inspector.showUserAgentStyles", true);
user_pref("devtools.jsonview.enabled", false);

// disable onboarding popups
user_pref("browser.eme.ui.firstContentShown", true);
user_pref("browser.engagement.downloads-button.has-used", true);
user_pref("browser.engagement.fxa-toolbar-menu-button.has-used", true);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("app.normandy.first_run", false);
user_pref("browser.translations.panelShown", true);
user_pref("media.videocontrols.picture-in-picture.video-toggle.has-used", true);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("browser.uitour.enabled", false);
user_pref("devtools.everOpened", true);
user_pref("devtools.performance.popup.intro-displayed", true);

// enable userchrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// privacy (from arkenfox)
// disable recommendation pane in addons
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
// disable submitting file hashes to google
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
// proxy or die!
user_pref("network.proxy.failover_direct", false);
user_pref("network.proxy.allow_bypass", false);
// ssl hardening
user_pref("security.ssl.require_safe_negotiation", true);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("security.mixed_content.block_display_content", true);
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_pbm", true);
user_pref("dom.security.https_only_mode_send_http_background_request", false);
// webrtc
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);
user_pref("media.peerconnection.ice.default_address_only", true);
// misc hardening
user_pref("dom.disable_window_move_resize", true);
user_pref("network.http.referer.spoofSource", false);