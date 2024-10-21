-- Configure DAP for Scala (Metals)
local dap = require('dap')

dap.configurations.scala = {
  {
    type = 'scala',
    request = 'launch',
    name = "Run or Test File",
    metals = {
      runType = "runOrTestFile",
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = "Test Target",
    metals = {
      runType = "testTarget",
    },
  },
}

dap.adapters.scala = function(callback, config)
  local metals_dap = require("metals").dap()
  callback(metals_dap)
end

