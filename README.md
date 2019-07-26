
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
* Install `resolvconf` (if this tools is not already installed). For ubuntu you can use: 
```
sudo apt install resolvconf
```

## Start F5 VPN client

### Install
Clone this repository to your favourite place and ```cd``` into this directory.

Run ```sudo ./install.sh``` script that help you to configure tool and prepare it to use. 

After installation use ```sap-vpn --help``` to see if tool was installed correctly and ready to use.

### Mode
#### Gateway

Add routes in CIDR notation in _routes.config_ files to let traffic to this ip's go through the VPN. 
(This step is optional if you don't want to use 'gateway' mode and going to use 'clinet' mode.)
#### Client

Nothing special need to be done.

### Run

Run SAP VPN:
```
sap-vpn <6-digits PIN>
```

