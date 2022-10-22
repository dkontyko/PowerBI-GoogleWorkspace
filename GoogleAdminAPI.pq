// This file contains your Data Connector logic
[Version = "0.1.0"]
section GoogleAdminAPI;

windowHeight = "600";
windowWidth = "1000";

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

// adapted from https://github.com/microsoft/DataConnectors/blob/master/samples/OAuthPKCE/PKCESample.pq
// see license at that repo

StartLogin = (resourceUrl, state, display) =>
    let
        codeVerifier = Text.NewGuid() & Text.NewGuid(),
        AuthorizeUrl = "https://accounts.google.com/o/oauth2/v2/auth?" & Uri.BuildQueryString([
            client_id = client_id, // TODO add before testing
            response_type = "code",
            code_challenge_method = "plain",
            code_challenge = codeVerifier,
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
            Context = codeVerifier
        ];
FinishLogin = (context, callbackUri, state) =>
    let
        Parts = Uri.Parts(callbackUri)[Query]
    in 
        TokenMethod(Parts[code], "authorization_code", context);

TokenMethod = (code, grant_type, optional verifier) =>
    let
        codeVerifier = if (verifier <> null) then [code_verifier = verifier] else [],
        codeParameter = if (grant_type = "authorization_code") then [code = code] else [refresh_token = code],
        query = codeVerifier & codeParameter & [
            client_id = client_id,
            //client_secret = client_secret, // Will Google require this???
            grant_type = grant_type,
            redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html"
        ],

        ManualHandlingStatusCodes = {400, 403},

        Response = Web.Contents("https://oauth2.googleapis.com", [
            Content = Text.ToBinary(Uri.BuildQueryString(query)),
            Headers=[
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ]
        ]),
        Parts = Json.Document(Response)
    in 
        // checking for error in response
        if(Parts[Error]? <> null) then
            error Error.Record(Parts[error], Parts[message]?)
        else
            Parts;

Refresh = (resourceUrl, refresh_token) => TokenMethod(refresh_token, "refresh_token");

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
