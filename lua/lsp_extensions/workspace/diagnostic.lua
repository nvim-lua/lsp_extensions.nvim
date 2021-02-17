local protocol = vim.lsp.protocol
local if_nil = vim.F.if_nil

local DiagnosticSeverity = protocol.DiagnosticSeverity

local loclist_type_map = {
  [DiagnosticSeverity.Error] = 'E',
  [DiagnosticSeverity.Warning] = 'W',
  [DiagnosticSeverity.Information] = 'I',
  [DiagnosticSeverity.Hint] = 'I',
}

local to_severity = function(severity)
  if not severity then return nil end
  return type(severity) == 'string' and DiagnosticSeverity[severity] or severity
end

local filter_to_severity_limit = function(severity, diagnostics)
  local filter_level = to_severity(severity)
  if not filter_level then
    return diagnostics
  end

  return vim.tbl_filter(function(t) return t.severity == filter_level end, diagnostics)
end

local filter_by_severity_limit = function(severity_limit, diagnostics)
  local filter_level = to_severity(severity_limit)
  if not filter_level then
    return diagnostics
  end

  return vim.tbl_filter(function(t) return t.severity <= filter_level end, diagnostics)
end

-- Keep it as a global so it stays between reloads, caches and exposed to view.
_LspExtensionsWorkspaceCache = _LspExtensionsWorkspaceCache or {}

local M = {}

-- { client: stuff }
M.diagnostic_cache = _LspExtensionsWorkspaceCache

M.handler = function(err, method, result, client_id, bufnr, config)
  vim.lsp.diagnostic.on_publish_diagnostics(err, method, result, client_id, bufnr, config)

  if not result then return end

  bufnr = bufnr or vim.uri_to_bufnr(result.uri)

  if not M.diagnostic_cache[client_id] then
    M.diagnostic_cache[client_id] = {}
  end

  local diagnostics = result.diagnostics

  local counts = {}
  for _, severity in ipairs(DiagnosticSeverity) do
    counts[to_severity(severity)] = vim.lsp.diagnostic.get_count(bufnr, severity, client_id)
  end


  M.diagnostic_cache[client_id][bufnr] = {
    diagnostics = diagnostics,
    counts = counts,
  }
end

M.get_count = function(bufnr, severity)
  if bufnr == 0 or not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  severity = to_severity(severity)

  local count = 0
  local clients = vim.lsp.buf_get_clients(bufnr)

  for client_id, _ in pairs(clients) do
    for _, diagnostic_cache in pairs(M.diagnostic_cache[client_id] or {}) do
      if diagnostic_cache.counts then
        count = count + diagnostic_cache.counts[severity]
      end
    end
  end

  return count
end

M.set_qf_list = function(opts)
  opts = opts or {}

  local open_qflist = if_nil(opts.open_qflist, true)

  local bufnr = vim.api.nvim_get_current_buf()
  local diags_by_buffer = M.get(bufnr)

  for diag_bufnr, diags in pairs(diags_by_buffer) do
    if opts.severity then
      diags_by_buffer[diag_bufnr] = filter_to_severity_limit(opts.severity, diags)
    elseif opts.severity_limit then
      diags_by_buffer[diag_bufnr] = filter_by_severity_limit(opts.severity_limit, diags)
    end
  end

  -- P(diags_by_buffer)
  -- if true then return end

  local item_list = {}

  local insert_diag = function(diag_bufnr, diag)
    local pos = diag.range.start
    local row = pos.line

    local col_ok, col = pcall(vim.lsp.util.character_offset, bufnr, row, pos.character)
    if not col_ok then
      col = pos.character
    end

    local line = (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false) or {""})[1] or ""

    table.insert(item_list, {
      bufnr = diag_bufnr,
      lnum = row + 1,
      col = col + 1,
      text = line .. " | " .. diag.message,
      type = loclist_type_map[diag.severity or DiagnosticSeverity.Error] or 'E',
    })
  end

  for diag_bufnr, diags in pairs(diags_by_buffer) do
    for _, v in ipairs(diags) do
      insert_diag(diag_bufnr, v)
    end
  end

  vim.fn.setqflist({}, 'r', { title = 'LSP Diagnostics'; items = item_list; })

  if open_qflist then
    vim.cmd [[copen]]
  end
end

function M.get(bufnr)
  local result = {}

  for client_id, _ in pairs(vim.lsp.buf_get_clients(bufnr)) do
    for diag_bufnr, diag_cache in pairs(M.diagnostic_cache[client_id] or {}) do
      if not result[diag_bufnr] then
        result[diag_bufnr] = {}
      end

      vim.list_extend(result[diag_bufnr], diag_cache.diagnostics or {})
    end
  end

  return result
end

return M
