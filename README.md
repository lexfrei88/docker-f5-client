
# F5 VPN client

This Docker image provides the F5 VPN Client, which can be used without local installation.
The docker image allows two operating modes:

* Using F5 VPN client with local installation like a local installed VPN client.
* Use the running Docker container as router/gateway to avoid VPN split tunneling.
  In this mode, the only modification to your local system is a route for your VPN subnets to the running Docker container.


## Setup

* Install Docker. **Important:** Do **not** use the packages provided by your
  distribution packages sources.
  Use the officical resources from docker: https://docs.docker.com/engine/installation/.


### Mac

* If you want to use the gateway mode:
  For automatic route setup on Mac you need to install ```iproute2mac``` via homebrew.


## Start F5 VPN client

### Gateway mode

Clone this repository to your favourite place and ```cd``` into the directory.

Auto route setup for connecting to a VPN network (needs root add/remove routes):
Add routes in CIDR notation in routes.config files. 
Run
```
sudo ./f5fpc-vpn.sh gateway --host https://connectwdf11.sap.com --user <C-user> --password <RSA-passcode>
```

For more information and options see
```
./f5fpc-vpn.sh -h
```

### Known issues

Seems like some of the SAP URL could not be resolved with usual DNS servers, so you need to add them into hosts file
to be able to open them in browser. For example on linux add `10.67.76.20     github.wdf.sap.corp` in `/etc/hosts` to use SAP github

