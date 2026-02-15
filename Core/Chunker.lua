local Tokenizer = Chattery.Tokenizer;

------------

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
    return Chattery.Settings.GetSetting(Chattery.Setting.SplitMarker);
end

function Chunker.ShouldShowMessageIndex()
    return Chattery.Settings.GetSetting(Chattery.Setting.ShowMessageIndex);
end

function Chunker.ShouldHandleRPSyntax()
    return Chattery.Settings.GetSetting(Chattery.Setting.HandleRPSyntax);
end

function Chunker.SplitMessageByWords(message)
    local parts = {};

    for word, spaces in message:gmatch("(%S+)(%s*)") do
        tinsert(parts, word .. spaces);
    end

    return parts;
end

function Chunker.SplitMessage(message, chunkSize)
    chunkSize = chunkSize or Chattery.Constants.CHUNK_SIZES.Default;

    local prefix, suffix = Chunker.GetPaddingText();
    local suffixSize = #suffix;

    local prefixes = {};
    local rawChunks = {};
    local current = "";

    local splitMarker = Chunker.GetMessageSplitMarker();
    local handleRPSyntax = Chunker.ShouldHandleRPSyntax();

    local function maxOverhead()
        local index = #rawChunks + 1;
        local newPrefix;
        if Chunker.ShouldShowMessageIndex() then
            newPrefix = format("[%d] ", index);
        else
            newPrefix = prefix;
        end

        tinsert(prefixes, index, newPrefix);
        local paddingSize = #newPrefix + suffixSize + (2 * #splitMarker) + 1;
        return paddingSize;
    end

    local function usableLength()
        local overhead = maxOverhead();
        return chunkSize - overhead;
    end

    local rpDelimStack = {};
    local rpReopenStack = nil;

    local function flushRaw()
        if #current == 0 then
            return;
        end

        local out = current;

        if #rpDelimStack > 0 then
            out = AppendClosers(out, rpDelimStack);
            rpReopenStack = CopyTable(rpDelimStack);
        end

        tinsert(rawChunks, out);
        current = "";
    end

    local tokens = Tokenizer:Tokenize(message);
    for _, token in ipairs(tokens) do
        local text = token.Value;
        if token.Type == Tokenizer.TOKEN_TYPE.Link then
            local _, _, displayText = LinkUtil.ExtractLink(text);
            local visibleLength = #displayText;

            if #current + visibleLength > usableLength() then
                flushRaw();
            end

            current = current .. text;
        else
            local parts = Chunker.SplitMessageByWords(token.Value);
            for _, part in ipairs(parts) do
                local partLength = #part;

                if #current + partLength > usableLength() then
                    flushRaw();
                    if rpReopenStack then
                        current = PrependOpeners("", rpReopenStack);
                        rpReopenStack = nil;
                    end
                end

                current = current .. part;

                if handleRPSyntax then
                    UpdateDelimStack(part, rpDelimStack);
                end
            end
        end
    end

    flushRaw();

    local finalChunks = {};
    local numFinalChunks = #rawChunks;

    for i, content in ipairs(rawChunks) do
        local startMarker = (i > 1) and (splitMarker .. " ") or "";
        local endMarker = (i < numFinalChunks) and splitMarker or "";

        if strbyte(content, -1) ~= 32 then
            content = content .. " ";
        end

        local chunk = prefixes[i] .. startMarker .. content .. endMarker .. suffix;
        tinsert(finalChunks, chunk);
    end

    return finalChunks;
end

------------

Chattery.Chunker = Chunker;