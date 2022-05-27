return function (class)

  class.options.papersize = "74mm x 105mm"

  class:loadPackage("masters", {{
      id = "right",
      firstContentFrame = "content",
      frames = {
        content = {
          left = "12mm",
          right = "100%pw-6mm",
          top = "8mm",
          bottom = "100%ph-6mm"
        }
      }
    }})
  class:loadPackage("twoside", {
      oddPageMaster = "right",
      evenPageMaster = "left"
    })

  if class.options.crop then
    class:loadPackage("crop")
  end

  SILE.setCommandDefaults("imprint:font", { size = "7pt" })

end
