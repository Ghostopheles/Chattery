local Tokenizer = Chattery.Tokenizer;

------------

local function GetSetting(setting)
	return Chattery.Settings.GetSetting(setting);
end

---@class ChatteryRPDelim
---@field open string
---@field close string

---@return ChatteryRPDelim
local function MakeDelim(startChar, endChar)
    return {
        open = startChar,
        close = endChar or startChar
    };
end

local NPC_SPEECH_TOKEN = "|| ";

---@type ChatteryRPDelim[]
local RP_SYNTAX_DELIMS = {
    MakeDelim('"'),
    MakeDelim("*"),
    MakeDelim("**"),
    MakeDelim("(", ")"),
    MakeDelim("<", ">"),
    MakeDelim("((", "))"),
};

table.sort(RP_SYNTAX_DELIMS, function(a, b)
    return #a.open > #b.open;
end);

------------

---@param text string
---@param stack ChatteryRPDelim[]
local function UpdateDelimStack(text, stack)
    local i = 1;

    while i <= #text do
        local matched = false;

        local top = stack[#stack];
        if top then
            local close = top.close;
            if text:sub(i, i + #close - 1) == close then
                tremove(stack);
                i = i + #close;
                matched = true;
            end
        end

        if not matched then
            for _, delim in ipairs(RP_SYNTAX_DELIMS) do
                if text:sub(i, i + #delim.open - 1) == delim.open then
                    tinsert(stack, delim);
                    i = i + #delim.open;
                    matched = true;
                    break;
                end
            end
        end

        if not matched then
            i = i + 1;
        end
    end
end

---@param text string
---@param stack ChatteryRPDelim[]
local function AppendClosers(text, stack)
    for i = #stack, 1, -1 do
        text = text .. stack[i].close;
    end

    return text;
end

---@param text string
---@param stack ChatteryRPDelim[]
local function PrependOpeners(text, stack)
    for i = 1, #stack do
        text = text .. stack[i].open;
    end

    return text;
end

------------

local MSG_PREFIX, MSG_SUFFIX = "", "";

---@class ChatteryChunker
local Chunker = {};

function Chunker.GetPaddingText()
    return MSG_PREFIX, MSG_SUFFIX;
end

function Chunker.SetPadding(prefix, suffix)
    if prefix then
        MSG_PREFIX = prefix;
    end

    if suffix then
        MSG_SUFFIX = suffix;
    end
end

function Chunker.GetMessageSplitMarker()
    return GetSetting(Chattery.Setting.SplitMarker);
end

function Chunker.ShouldShowMessageIndex()
    return GetSetting(Chattery.Setting.ShowMessageIndex);
end

function Chunker.ShouldHandleRPSyntax()
    return GetSetting(Chattery.Setting.HandleRPSyntax);
end

function Chunker.SplitMessageByWords(message)
    local parts = {};

    for word, spaces in message:gmatch("(%S+)(%s*)") do
        tinsert(parts, word .. spaces);
    end

    return parts;
end

function Chunker.ShouldHandleNPCSpeech(chatType)
	return GetSetting(Chattery.Setting.HandleNPCSpeech) and Chattery.Constants.NPC_CHAT_TYPES[chatType] ~= nil;
end

function Chunker.ShouldHandleCapitalization()
	return GetSetting(Chattery.Setting.HandleCapitalization);
end

function Chunker.ShouldHandlePunctuation()
	return GetSetting(Chattery.Setting.HandlePunctuation);
end

function Chunker.SplitMessage(message, chunkSize, chatType)
    chunkSize = chunkSize or Chattery.Constants.CHUNK_SIZES.Default;

    local prefix, suffix = Chunker.GetPaddingText();
    local suffixSize = #suffix;

    local prefixes = {};
    local rawChunks = {};
    local current = "";

    local splitMarker = Chunker.GetMessageSplitMarker();
    local handleRPSyntax = Chunker.ShouldHandleRPSyntax();

    local npcPrefix = "";
    if Chunker.ShouldHandleNPCSpeech(chatType) and (message:sub(1, #NPC_SPEECH_TOKEN) == NPC_SPEECH_TOKEN) then
        npcPrefix = NPC_SPEECH_TOKEN;
        message = message:sub(#NPC_SPEECH_TOKEN + 1);
    end

    local function getPrefix(index)
        if Chunker.ShouldShowMessageIndex() then
            return format("[%d] ", index);
        else
            return prefix;
        end
    end

    local function usableLength()
        local index = #rawChunks + 1;
        local prefixSize = #getPrefix(index);
        -- very conservative overhead padding
        -- this is to guarantee that the chunk size never exceeds the message limit
        local overhead = prefixSize + suffixSize + (2 * #splitMarker) + #npcPrefix + 2;
        return chunkSize - overhead;
    end

    local rpDelimStack = {};
    local rpReopenStack = nil;

    local function overflows(text, addedLength)
        local closerSize = 0;
        if handleRPSyntax then
            local stack = CopyTable(rpDelimStack);
            UpdateDelimStack(text, stack);
            for _, delim in ipairs(stack) do
                closerSize = closerSize + #delim.close;
            end
        end
        return #current + (addedLength or #text) + closerSize > usableLength();
    end

    local function flushRaw()
        if #current == 0 then
            return;
        end

        local out = current;

        if #rpDelimStack > 0 then
            out = AppendClosers(out, rpDelimStack);
            rpReopenStack = CopyTable(rpDelimStack);
        end

        tinsert(prefixes, getPrefix(#rawChunks + 1));
        tinsert(rawChunks, out);
        current = "";
    end

    local function newChunk()
        flushRaw();
        if rpReopenStack then
            current = PrependOpeners("", rpReopenStack);
            rpReopenStack = nil;
        end
    end

    local function append(text)
        current = current .. text;
        if handleRPSyntax then
            UpdateDelimStack(text, rpDelimStack);
        end
    end

    local tokens = Tokenizer:Tokenize(message);
    for _, token in ipairs(tokens) do
        if token.Type == Tokenizer.TOKEN_TYPE.Link then
            local _, _, displayText = LinkUtil.ExtractLink(token.Value);

            if overflows("", #displayText) then
                newChunk();
            end

            current = current .. token.Value;
        else
            for _, part in ipairs(Chunker.SplitMessageByWords(token.Value)) do
                if overflows(part) then
                    newChunk();
                end

                -- Word longer than a whole chunk: hard-split at the byte limit.
                while overflows(part) do
                    local piece = part:sub(1, math.max(usableLength() - #current, 0));
                    while #piece > 1 and overflows(piece) do
                        piece = piece:sub(1, #piece - 1);
                    end
                    if #piece == 0 then
                        break;
                    end

                    append(piece);
                    newChunk();
                    part = part:sub(#piece + 1);
                end

                append(part);
            end
        end
    end

    flushRaw();

    if Chunker.ShouldHandleCapitalization() and #rawChunks > 0 then
        rawChunks[1] = rawChunks[1]:gsub("(%A*)(%l)", function(pre, letter)
            return pre .. letter:upper();
        end, 1);
    end

    if Chunker.ShouldHandlePunctuation() and #rawChunks > 0 then
        local last = rawChunks[#rawChunks];
        local lastChar = last:sub(-1);
        if lastChar ~= "." and lastChar ~= "!" and lastChar ~= "?" then
            rawChunks[#rawChunks] = last .. ".";
        end
    end

    local finalChunks = {};
    local numFinalChunks = #rawChunks;

    for i, content in ipairs(rawChunks) do
        local startMarker = (i > 1) and (splitMarker .. " ") or "";
        local endMarker = (i < numFinalChunks) and splitMarker or "";

        if strbyte(content, -1) ~= 32 then
            content = content .. " ";
        end

        local chunk = prefixes[i] .. npcPrefix .. startMarker .. content .. endMarker .. suffix;
        tinsert(finalChunks, chunk);
    end
    return finalChunks;
end

------------

Chattery.Chunker = Chunker;
