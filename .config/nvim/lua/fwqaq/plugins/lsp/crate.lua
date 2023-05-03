local crate_status, crate = pcall(require, "crate")

if not crate_status then
  return
end

crate.setup()
