CASILE.layout = "cep"

local class = SILE.documentState.documentClass

SILE.documentState.paperSize = SILE.paperSizeParser("110mm x 170mm")
SILE.documentState.orgPaperSize = SILE.documentState.paperSize

class:defineMaster({
    id = "right",
    firstContentFrame = "content",
    frames = {
      content = {
        left = "20mm",
        right = "100%pw-10mm",
        top = "20mm",
        bottom = "top(footnotes)"
      },
      runningHead = {
        left = "left(content)",
        right = "right(content)",
        top = "top(content)-10mm",
        bottom = "top(content)-2mm"
      },
      footnotes = {
        left = "left(content)",
        right = "right(content)",
        height = "0",
        bottom = "100%ph-15mm"
      }
    }
  })
class:mirrorMaster("right", "left")
SILE.call("switch-master-one-page", { id = "right" })

if class.options.crop() == "true" then class:setupCrop() end

SILE.setCommandDefaults("imprint:font", { size = "7pt" })
