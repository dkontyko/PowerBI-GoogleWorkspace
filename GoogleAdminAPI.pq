// This file contains your Data Connector logic
[Version = "0.1.0"]
section GoogleAdminAPI;

[DataSource.Kind="GoogleAdminAPI", Publish="GoogleAdminAPI.Publish"]
shared GoogleAdminAPI.Contents = (optional message as text) =>
    let
        _message = if (message <> null) then message else "(no message)",
        a = "Hello from GoogleAdminAPI: " & _message
    in
        a;

// Data Source Kind description
GoogleAdminAPI = [
    Authentication = [
        // Key = [],
        // UsernamePassword = [],
        // Windows = [],
        OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin
        ]
    ]
];

StartLogin = (resourceUrl, state, display) =>
    let
        AuthorizeUrl = "https://accounts.google.com/o/oauth2/v2/auth?" & Uri.BuildQueryString([
            client_id = client_id,
            scope = "https://www.googleapis.com/auth/admin.reports.audit.readonly",
            state = state,
            redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html"
        ])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = "https://oauth.powerbi.com/views/oauthredirect.html",
            WindowHeight = windowHeight,
            WindowWidth = windowWidth,
            Context = null
        ]

// Data Source UI publishing description
GoogleAdminAPI.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = GoogleAdminAPI.Icons,
    SourceTypeImage = GoogleAdminAPI.Icons
];

GoogleAdminAPI.Icons = [
    Icon16 = { Extension.Contents("GoogleAdminAPI16.png"), Extension.Contents("GoogleAdminAPI20.png"), Extension.Contents("GoogleAdminAPI24.png"), Extension.Contents("GoogleAdminAPI32.png") },
    Icon32 = { Extension.Contents("GoogleAdminAPI32.png"), Extension.Contents("GoogleAdminAPI40.png"), Extension.Contents("GoogleAdminAPI48.png"), Extension.Contents("GoogleAdminAPI64.png") }
];
