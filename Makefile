ADDON=Merchant
WOW=/Applications/World\ of\ Warcraft/_retail_/Interface/AddOns
CACHE=../wow/generated
CACHE_PRICE=PriceCache.lua

uninstall:
	rm -rf $(WOW)/$(ADDON)

install: uninstall
	cp -R $(ADDON) $(WOW)

$(ADDON)/$(CACHE_PRICE): $(CACHE)/$(CACHE_PRICE)
	cp $(CACHE)/$(CACHE_PRICE) $(ADDON)
	git --no-pager diff $@

cache: $(ADDON)/$(CACHE_PRICE) install

# Targets that do not represent actual files
.PHONY: uninstall install cache
