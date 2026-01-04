local M = {}

--- 刪除當前 buffer 的檔案
--- 會先顯示確認對話框，使用垃圾桶（如果可用）或直接刪除
function M.delete_current_file()
    local filepath = vim.api.nvim_buf_get_name(0)

    -- 檢查 buffer 是否有對應的檔案
    if filepath == "" or filepath == nil then
        vim.notify("當前 buffer 沒有關聯的檔案", vim.log.levels.WARN)
        return
    end

    -- 檢查檔案是否存在
    local stat = vim.loop.fs_stat(filepath)
    if not stat then
        vim.notify("檔案不存在: " .. filepath, vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- 顯示確認對話框
    vim.ui.select(
        { "否", "是" },
        {
            prompt = "確定要刪除檔案嗎？ " .. filename,
        },
        function(choice)
            if choice ~= "是" then
                return
            end

            local buf = vim.api.nvim_get_current_buf()
            local success = false

            -- 嘗試使用垃圾桶
            if vim.fn.executable("trash") == 1 then
                local result = vim.fn.system({"trash", filepath})
                if vim.v.shell_error == 0 then
                    success = true
                    vim.notify("檔案已移至垃圾桶: " .. filename, vim.log.levels.INFO)
                end
            end

            -- 垃圾桶不可用或失敗，使用直接刪除
            if not success then
                local delete_result = vim.fn.delete(filepath)
                if delete_result == 0 then
                    success = true
                    vim.notify("檔案已刪除: " .. filename, vim.log.levels.INFO)
                else
                    vim.notify("刪除檔案失敗: " .. filename, vim.log.levels.ERROR)
                    return
                end
            end

            -- 刪除成功後關閉 buffer
            if success then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    )
end

--- 建立新檔案
--- 使用輸入對話框取得檔案路徑，自動建立父目錄
function M.create_new_file()
    -- 取得當前檔案的目錄作為預設路徑
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = ""

    if current_file ~= "" then
        current_dir = vim.fn.fnamemodify(current_file, ":p:h")
    else
        current_dir = vim.fn.getcwd()
    end

    -- 顯示輸入對話框
    vim.ui.input({
        prompt = "新檔案路徑: ",
        default = current_dir .. "/",
    }, function(filepath)
        if not filepath or filepath == "" then
            return
        end

        -- 展開路徑（處理 ~ 等符號）
        filepath = vim.fn.expand(filepath)

        -- 檢查檔案是否已存在
        local stat = vim.loop.fs_stat(filepath)
        if stat then
            vim.ui.select(
                { "否", "是" },
                {
                    prompt = "檔案已存在，要開啟它嗎？ " .. vim.fn.fnamemodify(filepath, ":t"),
                },
                function(choice)
                    if choice == "是" then
                        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
                    end
                end
            )
            return
        end

        -- 取得父目錄
        local parent_dir = vim.fn.fnamemodify(filepath, ":h")

        -- 建立父目錄（如果不存在）
        if vim.fn.isdirectory(parent_dir) == 0 then
            local mkdir_result = vim.fn.mkdir(parent_dir, "p")
            if mkdir_result == 0 then
                vim.notify("無法建立目錄: " .. parent_dir, vim.log.levels.ERROR)
                return
            end
        end

        -- 建立並開啟新檔案
        vim.cmd("edit " .. vim.fn.fnameescape(filepath))
        vim.notify("已建立新檔案: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
    end)
end

return M
