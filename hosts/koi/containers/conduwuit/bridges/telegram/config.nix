{
  homeserver = {
    address = "http://conduwuit.docker:6167";
    domain = "stupid.fish";
    verify_ssl = false;
    software = "standard";
    http_retry_count = 4;
    status_endpoint = null;
    message_send_checkpoint_endpoint = null;
    async_media = false;
  };
  appservice = {
    address = "http://mautrix-telegram.docker:29317";
    hostname = "0.0.0.0";
    port = 29317;
    max_body_size = 1;
    database = "sqlite:/data/mautrix-telegram.db";
    id = "telegram";
    bot_username = "telegrambot";
    bot_displayname = "Telegram bridge bot";
    bot_avatar = "mxc://maunium.net/tJCRmUyJDsgRNgqhOgoiHWbX";
    provisioning = { enabled = false; };
    ephemeral_events = true;
    as_token._secret = "MAUTRIX_AS_TOKEN";
    hs_token._secret = "MAUTRIX_HS_TOKEN";
  };
  bridge = {
    username_template = "telegram_{userid}";
    alias_template = "telegram_{groupname}";
    displayname_template = "{displayname} (Telegram)";
    allow_matrix_login = false;
    create_group_on_invite = false;
    displayname_preference = [ "full name" "username" "phone number" ];
    displayname_max_length = 100;
    allow_avatar_remove = false;
    allow_contact_info = false;
    filter = {
      mode = "whitelist";
      list = [ 
        1183945448 # zachem
      ];
      users = false;
    };
    relay_user_distinguishers = [];
    permissions = {
      "*" = "relaybot";
      "@teidesu:stupid.fish" = "admin";
    };
    relaybot = {
      group_chat_invite = [ "@teidesu:stupid.fish" ];
      authless_portals = true;
      whitelist_group_admins = false;
      ignore_unbridged_group_chat = true;
      whitelist = [
        1787945512 # teidesu
      ];
    };
    encryption = {
      allow = true;
      default = false;
      appservice = false;
      require = false;
      allow_key_sharing = true;
      delete_keys = {
        delete_outbound_on_ack = false;
        dont_store_outbound = false;
        ratchet_on_decrypt = false;
        delete_fully_used_on_decrypt = true;
        delete_prev_on_new_session = true;
        delete_on_device_delete = true;
        periodically_delete_expired = true;
        delete_outdated_inbound = false;
      };
    };
  };
  telegram = {
    api_id._secret = "TELEGRAM_API_ID";
    api_hash._secret = "TELEGRAM_API_HASH";
    bot_token._secret = "TELEGRAM_BOT_TOKEN";
    catch_up = true;
    sequential_updates = true;
    exit_on_update_error = false;
    force_refresh_interval_seconds = 0;
  };
  logging = {
    version = 1;
    formatters = {
      simple = {
        format = "[%(asctime)s] [%(levelname)s@%(name)s] %(message)s";
      };
    };
    handlers = {
      console = {
        class = "logging.StreamHandler";
        formatter = "simple";
        stream = "ext://sys.stdout";
      };
    };
    loggers = {
      mau = { level = "DEBUG"; };
      telethon = { level = "INFO"; };
      aiohttp = { level = "INFO"; };
    };
    root = {
      level = "DEBUG";
      handlers = [ "console" ];
    };
  };
}