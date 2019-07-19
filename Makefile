.DEFAULT_GOAL := start 

start:
	@echo Install script to run SAP VPN...
	@./install.sh

clean:
	@echo Uninstall script to run SAP VPN...
	@sudo rm /usr/bin/sap-vpn

