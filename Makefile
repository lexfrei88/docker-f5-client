.DEFAULT_GOAL := install

install:
	@echo Install script to run SAP VPN...
	@./install.sh

uninstall:
	@echo Uninstall script to run SAP VPN...
	@sudo rm /usr/bin/sap-vpn

