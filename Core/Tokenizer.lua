---@class ChatteryTokenizer
local Tokenizer = {};

---@enum ChatteryTokenType
Tokenizer.TOKEN_TYPE = {
    Text = 1,
    Link = 2
};

function Tokenizer:Tokenize(message)
    local tokens = {};
    local i = 1;

    local pattern = "(|c[fn][^|]*|H[^|]+|h(.-)|h|r)";

    while i <= message:len() do
        local s, e, link = message:find(pattern, i);

        if not s then
            -- remaining text does not contain any links
            tinsert(tokens, {
                Type = self.TOKEN_TYPE.Text,
                Value = message:sub(i),
            });
            break;
        end

        if s > i then
            -- grabs the text before the link
            tinsert(tokens, {
                Type = self.TOKEN_TYPE.Text,
                Value = message:sub(i, s - 1),
            });
        end

        tinsert(tokens, {
            Type = self.TOKEN_TYPE.Link,
            Value = link
        });

        i = e + 1;
    end

    return tokens;
end

------------

Chattery.Tokenizer = Tokenizer;