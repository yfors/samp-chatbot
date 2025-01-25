 /// Copyright (c) SimoSbara & Socket, All Repository Contributors.

/**
 * $ ai.io.pwn
 */

/// required compile with "_compiler_"
/// @summary If you want to send a request to the bot with global status, you can use (-1) as the value in the parameter after the string in "RequestToChatBot"

#include <a_samp>
#include <a_http>
#include <core>
#include <float>

#define __DEBUG

#define __DCC // no discord? remove here
#if defined __DCC
    #define API_CHANNEL      "0000111100001111" // your channel
    /// @summary If you don't change the value in the definition above then if you activate the AI ​​Discord chat-bot there will be no response.
    #include <discord-connector>

    new DCC_Channel:__channel;
    #define @resetchannel \
        __channel = DCC_FindChannelById("");
    /// ^ override channel-id
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
#define FIRST_QUEST "welcome message"                               // first question
//
#include "samp-chatbot.inc"

new _request_;

new _rand_words_[][] = { // random words
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

new GetSystemPrompt [ 128 ],
    GetSystemResponse [ MAX_PLAYERS ][ MAX_TEXT_RESPONSE ];

#define func::%0(%1) \             
    forward %0(%1); \
    public %0(%1)
/// ^ function
#define _func:: \             
    stock
/// ^ stock
#define elif \          
    else if
/// ^ else if

#define @resetprompt \
    SetSystemPrompt("");
/// ^ override prompt
_func:: SetSystemPromptEx(__prompt[] = "Assistant")
{
    @resetprompt
    SetSystemPrompt __prompt;

    format GetSystemPrompt, sizeof ( GetSystemPrompt ), "%s", __prompt;

    return 1;
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
        case 3 .. 4: {
            goto default_model;
        }
    }

default_model: // default here
    SetModel API_MODEL;

    return 1;
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
    _request_ = 0;

#if defined __DCC
    @resetchannel
    __channel = DCC_FindChannelById(API_CHANNEL);

    new fmt [ 128 ];
    format fmt, sizeof ( fmt ), "%s is Online!", GetSystemPrompt;
    DCC_SendChannelMessage __channel, fmt;
#endif

    SetTimer "__model_AI", API_C_T_MODEL, true;

    return 1;
}

public OnFilterScriptInit ()
{
    Initialize.AI();

    return 1;
}

public OnFilterScriptExit ()
{
    return 1;
}

public OnPlayerSpawn ( \ 
    playerid )
{
    RequestToChatBot FIRST_QUEST, playerid; // send first question

    return 1;
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
    
        if ( __isBot ) // fix loop, check chat is not from bot
        {
            return 0;
        }
    
        if ( strfind ( __msg_content, "ai", true ) == 0 )
        {
            new prompt[144];
            strmid(prompt, __msg_content[2], 0, sizeof(prompt), strlen(__msg_content));
    
            if ( strlen ( prompt ) < 1) {
                new rand = random ( 5 ) + 1;
                switch ( rand ) {
                    case 1:
                        DCC_SendChannelMessage __channel, GetSystemPrompt;
                    case 2 .. 5:
                    {
                        new __rand = random(sizeof(_rand_words_));
                        new __fmt [ 32 ];
                        strmid(__fmt, _rand_words_[rand], 0, strlen(_rand_words_[__rand]), 31);
                            
                        new fmt [ 128 ];
                        format(fmt, sizeof(fmt), "%s", __fmt);
                        DCC_SendChannelMessage __channel, fmt;
                    }
                }
            }
    
            ++_request_;
            RequestToChatBot(prompt, _:__author);
    
            return 0;
        }
        return 1;
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
                     SendClientMessage playerid, -1, GetSystemPrompt;
                case 2 .. 5:
                {
                    new __rand = random(sizeof(_rand_words_));
                    new __fmt [ 32 ];
                    strmid(__fmt, _rand_words_[rand], 0, strlen(_rand_words_[__rand]), 31);
                        
                    new fmt [ 128 ];
                    format(fmt, sizeof(fmt), "%s", __fmt);
                    SendClientMessage playerid, -1, fmt;
                }
            }
        }

        ++_request_;
        RequestToChatBot prompt, playerid;

        return 0;
    }
    return 1;
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
        format GetSystemResponse[id], MAX_TEXT_RESPONSE, "%s", response;
        
        if ( strlen ( response ) < 144 ) { /// @summary if the chat is below 144 it will be given in the form of a player message
            new fmt [ 144 + 1 ];
            format fmt, sizeof(fmt), "%s", GetSystemResponse[id];
            SendClientMessage id, -1, fmt;
        }
        else {
            new _username_[ MAX_PLAYER_NAME + 1 ];
            GetPlayerName id, _username_, sizeof(_username_);

            new fmt [ 128 ];
            format fmt, sizeof(fmt), "{FFF070}Hi, %s", _username_;

            ShowPlayerDialog id, \
                CHATBOT_DIALOG, DIALOG_STYLE_MSGBOX, fmt, GetSystemResponse[id], "Close", "";
        }
    } else { /// @summary otherwise it will be given in the form of player dialogue
        format GetSystemResponse[id], MAX_TEXT_RESPONSE, "%s", response;
        #if defined __DCC
            DCC_SendChannelMessage __channel, GetSystemResponse[id];
        #endif
    }

#if defined __DEBUG
    printf "response=%d, request=%d", id, _request_;
#endif
    return 1;
}

