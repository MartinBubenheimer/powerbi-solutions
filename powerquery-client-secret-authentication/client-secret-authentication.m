// PowerQuery sample code for HTTP authentication workflow
// With client ID and client secret from app registration to get a bearer token.
// What goes into header or body and what field names are valid depends on host implementation of the authentication workflow
// This example assumes a JSON response. You need to modify part 2 for other formats, e.g., CSV.

let
    // ─── Configuration ───────────────────────────────────────────────
    tokenHost     = "https://auth.example.com",
    tokenPath     = "/oauth/token",

    apiHost       = "https://api.example.com",
    apiPath       = "/v1/data",

    clientId      = "YOUR_CLIENT_ID",
    clientSecret  = "YOUR_CLIENT_SECRET",

    bodyFields    = [
        grant_type    = "client_credentials",
        client_id     = clientId,
        client_secret = clientSecret
        // , scope = https://api.example.com/.default
    ],
    // ────────────────────────────────────────────────────────────────

    // 1) Request the token
    TokenRaw = Web.Contents(
        tokenHost,
        [
            RelativePath         = tokenPath,
            Content              = Text.ToBinary(Uri.BuildQueryString(bodyFields)),
            Headers              = [ #"Content-Type" = "application/x-www-form-urlencoded" ],
            ManualStatusHandling = {400, 401, 500}
        ]
    ),
    TokenStatus = Value.Metadata(TokenRaw)[Response.Status],
    TokenText   = Text.FromBinary(TokenRaw),
    TokenJson   = try Json.Document(TokenRaw) otherwise null,

    AccessToken =
        if TokenStatus = 200 and TokenJson?[access_token] <> null then
            TokenJson[access_token]
        else
            error
              "Token request failed (status "
              & Number.ToText(TokenStatus)
              & "): "
              & TokenText,

    // 2) Call the API with the Bearer token
    ApiRaw = Web.Contents(
        apiHost,
        [
            RelativePath         = apiPath,
            Headers              = [
                Authorization = "Bearer " & AccessToken,
                Accept        = "application/json" // use "*" if HTTP error 406 is returned
            ],
            ManualStatusHandling = {400, 401, 500}
        ]
    ),
    ApiStatus = Value.Metadata(ApiRaw)[Response.Status],
    ApiText   = Text.FromBinary(ApiRaw),
    ApiJson   = try Json.Document(ApiRaw) otherwise null,

    Result =
        if ApiStatus = 200 and ApiJson <> null then
            ApiJson
        else
            error
              "API request failed (status "
              & Number.ToText(ApiStatus)
              & "): "
              & ApiText
in
    Result
