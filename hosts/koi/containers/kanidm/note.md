notes for self:

## creating an oauth2 app:

```bash
kanidm system oauth2 create myapp myapp_display_name https://url.to.app
kanidm system oauth2 warning-insecure-client-disable-pkce myapp # optional, for oauth2-proxy
kanidm system oauth2 prefer-short-username myapp # optional
kanidm system oauth2 show-basic-secret myapp
kanidm system oauth2 add-redirect-url myapp https://url.to.app/oauth2/callback # the default path for oauth2-proxy

# adding users to the app
kanidm group create myapp_users
kanidm group add-members myapp_users teidesu
kanidm system oauth2 update-scope-map myapp myapp_users email openid profile
```

## oauth2 proxy env:
```bash
OAUTH2_PROXY_COOKIE_SECRET=...
OAUTH2_PROXY_CLIENT_SECRET=...
```