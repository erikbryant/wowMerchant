ADDON=Merchant
WOW=/Applications/World\ of\ Warcraft/_retail_/Interface/AddOns

uninstall:
	rm -rf $(WOW)/$(ADDON)

install: uninstall
	cp -R $(ADDON) $(WOW)

# Targets that do not represent actual files
.PHONY: uninstall install
