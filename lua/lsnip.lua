local ls = require('luasnip')

local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local postfix = require('luasnip.extras.postfix').postfix
local l = require('luasnip.extras').l -- lambda

function reused_func(args, snip, user_arg_1)
    return user_arg_1
end

ls.add_snippets("all", {
    s('lorem', {
        t(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
        )
    }),
    s('mline', t({ 'line 1', 'line 2' })),
    s('insert', {
        t({ "1. " }), i(1, "type text..."),
        t({ "", "2. " }), i(2, "this is default text"),
        t({ '', '3. ' }), i(0),

    }),
    s('trig', {
        i(1),
        f(
            function(args, snip, user_arg_1) return user_arg_1 .. args[1][1] end,
            { 1 },
            { user_args = { "Will be appended to text from i(0)" } }

        ),
        i(0)
    }),
    s('rf', {

        f(
            reused_func,
            {},
            { user_args = { "user_arg_1" } }
        ),
        f(
            reused_func,
            {},
            { user_args = { "arg 21" } }
        )
    }),
    s({ trig = "b(%d)", regTrig = true }, {
        f(function(args, snip)
            return "Captured Text: " .. snip.captures[1] .. "."
        end, {})

    }),
    postfix(".br", {
        -- f(function(
        --     _, parent
        -- )
        --     return "[" .. parent.snippet.env.POSTFIX_MATCH .. "]"
        -- end)
        l("[" .. l.POSTFIX_MATCH .. "]")
    }),
    s(
        'choice',

        {
            i(2, 'stop here ...'),
            c(1, {
                t('Option A: Pure Text'),
                i(nil, "Option B: Editable Text"),
                sn(nil, {
                    t("Option C: Include Insertion "), i(1, "type here...")
                })
            }) }
    )
})

ls.add_snippets("javascript", {
    s("get", {
        i(1, "count"),
        f(function(args)
            local n = tonumber(args[1][1]) or 1
            local out = {}
            for j = 1, n do
                table.insert(out, ("get%02d() { return this._%02d }"):format(j, j))
            end
            return out
        end, { 1 }),
    })
})

-- ls.add_snippets("javascript", {
--     s("lorem", {
--         i(1, "count"),
--         f(function(args)
--             local n = tonumber(args[1][1]) or 1
--             local out = {}
--             for j = 1, n do
--                 table.insert(out, ("get%02d() { return this._%02d }"):format(j, j))
--             end
--             return out
--         end, { 1 }),
--     })
-- })
