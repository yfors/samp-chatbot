/**
 * $ ai.io.pwn
 */

/// required compile with "_compiler_"

#include "a_samp"
#include "a_http"

#define __DEBUG

#define __DCC
#if defined __DCC
    #define API_CHANNEL      "000123456789" // your discord server channel
    #include "discord-connector"

    new DCC_Channel:__channel;
    #define @resetchannel \
        __channel = DCC_FindChannelById("");
    /// ^ override channel-id
#endif

#define MAX_TEXT_RESPONSE (4096)                                                   // maximum length of text response
#define API_KEY        "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" // your api token
#define API_MODEL      "llama3-8b-8192"                                          // your default api model
#define API_PROMPT     "Assistant SA-MP"                                        // your api prompt
#define API_STATUS     "🔥🔥"                                                  // your bot activity status
#define API_TIMER      (1200000)                                              // time miliseconds change a.i model
#define FIRST_QUEST    "welcome message"                                     // first question
#include "samp-chatbot.inc"

#define MAX_FMT_STRING (520)
new string_ [ MAX_FMT_STRING ];

#define @resetstring \
    string_ = "";
/// ^ override string_

new request;

enum
{
    CHATBOT_DIALOG = 1945
};

new req_msg [ MAX_PLAYERS ] [ 520 ];
new GetSystemPrompt [ 128 ],
    GetSystemResponse [ MAX_PLAYERS ][ 4096 ];

#define @resetprompt \
    SetSystemPrompt("");
/// ^ override prompt
stock SetSystemPromptEx (__prompt[] = "Assistant")
{
    @resetprompt
    SetSystemPrompt __prompt;

    format GetSystemPrompt, sizeof ( GetSystemPrompt ), "%s", __prompt;

    return true;
}

#define client. client_
forward client_Model ();
public client_Model ()
{
    new rand = random ( 4 ) + 1;
    switch ( rand ) {
        case 1: {
            SetModel "gemma2-9b-it"; // gemma2 - 9b param
            print "AI is gemma2-9b Now!"
        }
        case 2: {
            SetModel "llama3-70b-8192"; // llma 3 - 70b param
            print "AI is llma3-70b Now!"
        }
        case 3 .. 4: {
            goto default_model;
        }
    }

default_model: // default here
    SetModel API_MODEL;

    return true;
}
forward client_Initialize ()
public client_Initialize ()
{
    request = 0;

    SelectChatBot LLAMA;
    SetAPIKey API_KEY;
    SetModel API_MODEL;
    SetSystemPromptEx API_PROMPT;

#if defined __DCC
    DCC_SetBotActivity API_STATUS;
    
    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);

    @resetstring
    format string_, sizeof ( string_ ), "%s is Online!", GetSystemPrompt;
    DCC_SendChannelMessage __channel, string_;
#endif

    SetTimer "client_Model", API_TIMER, true;

    return true;
}

public OnFilterScriptInit ()
{
    client.Initialize();
    return true;
}
public OnFilterScriptExit ()
{
    return true;
}
public OnPlayerSpawn (playerid)
{
    RequestToChatBot FIRST_QUEST, playerid;
    return true;
}

#if defined __DCC
public DCC_OnMessageCreate ( DCC_Message: message )
{
    /**
     * Example: "ai, How Are you?"
     * Example: "ai, My name is S, you?"
     * Example: "ai, What is Los Santos?"
     */

    new
        __msg_content [ 144 + 1 ],
        DCC_User:__author,
        bool:__isBot
    ;

    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);

    DCC_GetMessageContent (message, __msg_content);
    DCC_GetMessageAuthor (message, __author);
    DCC_IsUserBot (__author, __isBot);

    if ( __isBot )
    {
        return false;
    }

    new prompt[ 144 + 1 ];
    if ( strfind ( __msg_content, "ai", true ) == 0 )
    {
        strmid(prompt, __msg_content[2], 0, sizeof(prompt), strlen(__msg_content));

        ++request;

        if ( strlen ( prompt ) < 1) {
            --request;
            new rand = random ( 2 ) + 1;
            switch ( rand ) {
                case 1:
                    DCC_SendChannelMessage __channel, GetSystemPrompt;
                case 2:
                {
                    @resetstring
                    format(string_, sizeof(string_), "%s", "Yes!");
                    DCC_SendChannelMessage __channel, string_;
                }
            }
        } else {
            req_msg[_:__author] = prompt;
            
            RequestToChatBot(prompt, _:__author);
        }
    }
    return true;
}
#endif

public OnPlayerText (playerid, text[])
{
    /**
     * Example: "ai, How Are you?"
     * Example: "ai, My name is yfors, you?"
     * Example: "ai, What is Los Santos?"
     */

    new prompt[ 144 + 1 ];
    if ( strfind ( text, "ai", true ) == 0 )
    {
        strmid(prompt, text[2], 0, sizeof(prompt), strlen(text));

        ++request;

        if ( strlen ( prompt ) < 1) {
            --request;
            new rand = random ( 2 ) + 1;
            switch ( rand ) {
                case 1:
                     SendClientMessage playerid, -1, GetSystemPrompt;
                case 2:
                {
                    @resetstring
                    format(string_, sizeof(string_), "%s", "Yes!");
                    SendClientMessage playerid, -1, string_;

                    return false;
                }
            }
        } else {
            req_msg[playerid] = prompt;

            RequestToChatBot prompt, playerid;

            return false;
        }
    }
    return true;
}

public OnChatBotResponse (prompt[],
                          response[], id)
{
#if defined __DCC
    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);
#endif
    new neq=0;
    new resLenght = strlen(response);
    if ( resLenght < 1 ) {
        printf "\nERR.. response:%d, request:%d, reason:%s\n", id, request, "No Response";

        --request;

        neq = 1;
    } 
    if ( IsPlayerConnected ( id ) )
    {
        new len_ = 144;
        if ( resLenght < len_ ) {

        #undef MAX_TEXT_RESPONSE
            #define MAX_TEXT_RESPONSE (len_)

            format GetSystemResponse[id], MAX_TEXT_RESPONSE, "%s", response;

            @resetstring
            format string_, sizeof(string_), "%s", GetSystemResponse[id];
            SendClientMessage id, -1, string_;
        }
        else {

            len_ = 512;

        #undef MAX_TEXT_RESPONSE
            #define MAX_TEXT_RESPONSE (len_)
            
            format GetSystemResponse[id], MAX_TEXT_RESPONSE, "%s", response;

            new _username_[ MAX_PLAYER_NAME + 1 ];
            GetPlayerName id, _username_, sizeof(_username_);

            @resetstring
            format string_, sizeof(string_), "{FFF070}Hi, %s", _username_;

            ShowPlayerDialog id,
                CHATBOT_DIALOG,
                    DIALOG_STYLE_MSGBOX,
                        string_, GetSystemResponse[id],
                            "Close", "";
        }
    } else {
#if defined __DCC
        new len_ = 2000;
        if ( resLenght > len_ ) {
            printf "\nERR.. response:%d, request:%d, reason:%s\n", id, request, "Limit Response";
            
            new __fmt[200];
            format __fmt, sizeof(__fmt), "%s%s", req_msg[id], "..simple";
            req_msg[id] = __fmt;

            ++request;
            RequestToChatBot(req_msg[id], id);

            neq = 1;
        } else {
        #undef MAX_TEXT_RESPONSE
            #define MAX_TEXT_RESPONSE (len_)

            format GetSystemResponse[id], MAX_TEXT_RESPONSE, "%s", response;
            DCC_SendChannelMessage __channel, GetSystemResponse[id];
        }
#endif
    }

#if defined __DEBUG
    if ( neq == 0 ) {
        if ( request == 1 )
            printf "\nresponse=%d, request=%d, lenght=%d", id, request, resLenght;
        else
            printf "response=%d, request=%d, lenght=%d", id, request, resLenght;
    }
#endif
    return true;
}
