/// Copyright (c) SimoSbara & Socket, All Repository Contributors.

/**
 * $ ai.io.pwn
 */

/// required compile with "_compiler_"

#include <a_samp>
#include <a_http>
#include <core>
#include <float>

#define __DEBUG

#define __DCC // no discord? remove here
#if defined __DCC
    #define API_CHANNEL      "0000111100001111" // your channel
    #include <discord-connector>

    new DCC_Channel:__channel;
    #define @resetchannel \
        __channel = DCC_FindChannelById("");
#endif

#define MAX_TEXT_RESPONSE (4096)                                            // max lenght text response
//
#define API_KEY "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" // your api token
//
#define API_MODEL      "llama3-8b-8192"                                   // your default api model
//
#define API_STATUS     "🔥🔥"                                            // your bot activity status
//
#define API_C_T_MODEL  (1200000)                                        // time miliseconds change a.i model
//
#define first_question "welcome message"                               // first question
//
#include "samp-chatbot.inc"

new __request;

new __rand_words[][] = { // random words
    "Apple", "Balloon", "Computer", "Dolphin", "Elephant", 
    "Forest", "Giraffe", "House", "Island", "Jungle", 
    "Kangaroo", "Lemon", "Mountain", "Night", "Ocean", 
    "Penguin", "Queen", "Rainbow", "Sunflower", "Tree", 
    "Unicorn", "Volcano", "Waterfall", "Xylophone", "Zebra", 
    "Apricot", "Bicycle", "Cloud", "Dragon", "Eagle", 
    "Flower", "Garden", "Helicopter", "Iceberg", "Jellyfish", 
    "Koala", "Lighthouse", "Moonlight", "Necklace", "Owl", 
    "Parrot", "Quokka", "River", "Starfish", "Turtle", 
    "Umbrella", "Vase", "Whale", "Yacht", "Zucchini"
};

enum
{
    CHATBOT_DIALOG = 1945
};

new __SYS_PROMPT [ 128 ],
    __SYS_RESPONSE [ MAX_PLAYERS ][ MAX_TEXT_RESPONSE ];

#define func::%0(%1) \             
    forward %0(%1); \
    public %0(%1)
#define __func:: \             
    stock
#define logprintf \          
    printf
#define logprint \         
    print
#define elif \          
    else if
#define ret(%0) \     
    return %0

#define @resetprompt \
    SetSystemPrompt("");
__func:: SetSystemPromptEx(__prompt[] = "Assistant")
{
    @resetprompt
    SetSystemPrompt __prompt;

    format __SYS_PROMPT, sizeof ( __SYS_PROMPT ), "%s", __prompt;

    ret(1);
}

forward __model_AI ();
public __model_AI ()
{
    new rand = random ( 4 ) + 1;
    switch ( rand ) {
        case 1: {
            SetModel "gemma2-9b-it"; // gemma
        }
        case 2: {
            SetModel "llama3-70b-8192"; // llma 3
        }
        case 3: {
            SetModel "llama-3.3-70b-specdec"; // llma 3.3
        }
        case 4: {
            goto __default;
        }
    }

__default: // default here
    SetModel API_MODEL;

    ret(1);
}

#define Initialize. Initialize_
func:: Initialize_AI ()
{
    SelectChatBot LLAMA;
    SetAPIKey API_KEY;
    SetModel API_MODEL;
    SetSystemPromptEx;

#if defined __DCC
    DCC_SetBotActivity API_STATUS;
#endif
    __request = 0;

#if defined __DCC
    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);

    new fmt [ 128 ];
    format fmt, sizeof ( fmt ), "%s is Online!", __SYS_PROMPT;
    DCC_SendChannelMessage __channel, fmt;
#endif

    SetTimer "__model_AI", API_C_T_MODEL, true;

    ret(1);
}

public OnFilterScriptInit ()
{
    Initialize.AI();
    ret(1);
}

public OnFilterScriptExit ()
{
    ret(1);
}

public OnPlayerSpawn ( \ 
    playerid )
{
    RequestToChatBot first_question, playerid;

    ret(1);
}

#if defined __DCC
    public DCC_OnMessageCreate ( DCC_Message: message )
    {
        /**
         * Example: "ai, How Are you?"
         * Example: "ai, My name is socket, you?"
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
            ret(0);
        }
    
        if ( strfind ( __msg_content, "ai", true ) == 0 )
        {
            new prompt[144];
            strmid(prompt, __msg_content[2], 0, sizeof(prompt), strlen(__msg_content));
    
            if ( strlen ( prompt ) < 1) {
                new rand = random ( 5 ) + 1;
                switch ( rand ) {
                    case 1:
                        #if defined __DCC
                            DCC_SendChannelMessage __channel, __SYS_PROMPT;
                        #endif
                    case 2 .. 3:
                    {
                        #if defined __DCC
                            new __rand = random(sizeof(__rand_words));
                            new __fmt [ 32 ];
                            strmid(__fmt, __rand_words[rand], 0, strlen(__rand_words[__rand]), 31);
                            
                            new fmt [ 128 ];
                            format(fmt, sizeof(fmt), "%s", __fmt);
                            DCC_SendChannelMessage __channel, fmt;
                        #endif
                    }
                    case 4 .. 5:
                    {
                        #if defined __DCC
                            new __rand = random(sizeof(__rand_words));
                            new __fmt [ 32 ];
                            strmid(__fmt, __rand_words[rand], 0, strlen(__rand_words[__rand]), 31);
                            
                            new fmt [ 128 ];
                            format(fmt, sizeof(fmt), "%s", __fmt);
                            DCC_SendChannelMessage __channel, fmt;
                        #endif
                    }
                }
            }
    
            ++__request;
            RequestToChatBot(prompt, _:__author);
    
            ret(0);
        }
    
        ret(1);
    }
#endif

public OnPlayerText (playerid, text[])
{
    /**
        * Example: "ai, How Are you?"
        * Example: "ai, My name is socket, you?"
        * Example: "ai, What is Los Santos?"
    */
    if ( strfind ( text, "ai", true ) == 0 )
    {
        new prompt[ 144 ];
        strmid(prompt, text[2], 0, sizeof(prompt), strlen(text));

        if ( strlen ( prompt ) < 1) {
            new rand = random ( 5 ) + 1;
            switch ( rand ) {
                case 1:
                     SendClientMessage playerid, -1, __SYS_PROMPT;
                case 2 .. 3:
                {
                    new __rand = random(sizeof(__rand_words));
                    new __fmt [ 32 ];
                    strmid(__fmt, __rand_words[rand], 0, strlen(__rand_words[__rand]), 31);
                        
                    new fmt [ 128 ];
                    format(fmt, sizeof(fmt), "%s", __fmt);
                    SendClientMessage playerid, -1, fmt;
                }
                case 4 .. 5:
                {
                    new __rand = random(sizeof(__rand_words));
                    new __fmt [ 32 ];
                    strmid(__fmt, __rand_words[rand], 0, strlen(__rand_words[__rand]), 31);
                        
                    new fmt [ 128 ];
                    format(fmt, sizeof(fmt), "%s", __fmt);
                    SendClientMessage playerid, -1, fmt;
                }
            }
        }

        ++__request;
        RequestToChatBot prompt, playerid;

        ret(0);

    }
    ret(1);
}

public OnChatBotResponse (prompt[],
                          response[], id)
{
#if defined __DCC
    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);
#endif
    if ( IsPlayerConnected(id) )
    {
        format __SYS_RESPONSE[id], MAX_TEXT_RESPONSE, "%s", response;
        
        if ( strlen( response ) < 144 ) {
            new fmt [ 144 + 1 ];
            format fmt, sizeof(fmt), "%s", __SYS_RESPONSE[id];
            SendClientMessage id, -1, fmt;
        }
        else {
            new _username_[ MAX_PLAYER_NAME + 1 ];
            GetPlayerName id, _username_, sizeof(_username_);

            new fmt [ 128 ];
            format fmt, sizeof(fmt), "{FFF070}Hi, %s", _username_;

            ShowPlayerDialog id, \
                CHATBOT_DIALOG, DIALOG_STYLE_MSGBOX, fmt, __SYS_RESPONSE[id], "Close", "";
        }
    } else {
        format __SYS_RESPONSE[id], MAX_TEXT_RESPONSE, "%s", response;
        #if defined __DCC
            DCC_SendChannelMessage __channel, __SYS_RESPONSE[id];
        #endif
    }

#if defined __DEBUG
    printf "response=%d, request=%d", id, __request;
#endif
    ret(1);
}

