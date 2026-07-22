-- Project-level filter: reads `toc-notes` from YAML and injects it as
-- <aside class="notes"> inside the auto-generated TOC slide produced by the
-- insee-clair extension's `toc-filter.lua` (section id="custom-toc-slide").

function Pandoc(doc)
  local notes_meta = doc.meta and doc.meta["toc-notes"]
  if not notes_meta then return doc end

  local notes_text = pandoc.utils.stringify(notes_meta)
  notes_text = notes_text:gsub("^%s+", ""):gsub("%s+$", "")
  local notes_html = '<aside class="notes">' .. notes_text .. '</aside>'

  for _, block in ipairs(doc.blocks) do
    if block.t == "RawBlock"
       and (block.format == "html" or block.format == "html5")
       and block.text:find("custom%-toc%-slide") then
      block.text = block.text:gsub("</section>", notes_html .. "</section>", 1)
      break
    end
  end

  return doc
end
