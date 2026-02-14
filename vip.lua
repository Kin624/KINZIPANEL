local config = {
    libName = "libil2cpp.so",
    offsets = {0x27C7694, 0x27C76E0},
    patches = {"~A8 MOV W19, #0x398", "~A8 MOV W1, #0x398"},
    originalVals = {},
    isActive = false
}

local function getBaseAddress(lib)
    local ranges = gg.getRangesList(lib)
    for _, r in ipairs(ranges) do
        if r.state == 'xa' then
            return r.start
        end
    end
    return ranges[1] and ranges[1].start or nil
end

function togglePremium()
    local base = getBaseAddress(config.libName)

    if not base then
        gg.alert("Hata: " .. config.libName .. " bulunamadı!")
        return
    end


    if not config.isActive then
        local confirm = gg.choice(
            {"Hayır", "Evet"},
            nil,
            "UYARI!\n\nBunu aktifleştirdiğinde sizi hile sunucuya atabilir.\n\nDevam etmek istiyor musunuz?"
        )

        if confirm ~= 2 then
            gg.toast("İşlem iptal edildi")
            return
        end

        for i, offset in ipairs(config.offsets) do
            local addr = base + offset
            config.originalVals[i] =
                gg.getValues({{address = addr, flags = gg.TYPE_DWORD}})[1].value
            gg.setValues({
                {address = addr, flags = gg.TYPE_DWORD, value = config.patches[i]}
            })
        end

        config.isActive = true
        gg.toast("AKTİF ")
    else
        
        for i, offset in ipairs(config.offsets) do
            gg.setValues({
                {address = base + offset, flags = gg.TYPE_DWORD, value = config.originalVals[i]}
            })
        end
        config.isActive = false
        gg.toast("KAPALI")
    end
end

function mainMenu()
    local status = config.isActive and " [AÇIK]" or " [KAPALI]"
    local menu = gg.choice({
        "Premium Arabalar" .. status,
        "Scripti Kapat"
    }, nil, "C21_Hack")

    if menu == 1 then togglePremium() end
    if menu == 2 then os.exit() end
end

gg.clearResults()
gg.toast("C21_HCK Script Başlatıldı...")

while true do
    if gg.isVisible() then
        gg.setVisible(false)
        mainMenu()
    end
    gg.sleep(100)
end