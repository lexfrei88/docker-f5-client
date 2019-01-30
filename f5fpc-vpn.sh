#!/bin/bash

F5FPC_HOME='/home/alex/DevOps/docker-f5fpc'
CONTAINER_NAME="f5fpc-vpn"
IMAGE_NAME="f5fpc-vpn-image"
F5FPC_ARGS=""
VPNHOST=""
USERNAME=""
PASSWORD=""
keep_running=1
NETWORKS=()

for cmd in docker ip ; do
	which "$cmd" > /dev/null 2> /dev/null
	if [ "$?" != "0" ] ; then
		echo "Unsatisfied dependencies: $cmd command not found!"
		exit 1
	fi
done

show_help() {
	cat << EOF
Usage: $0 <MODE> [<PARAMETERS...>]

Supported modes:
  - client
  - gateway

Supported parameters:
  -h --help	Show this help text
  -t --host     VPN host
  -u --user     VPN username
EOF
}

observe_f5fpc() {
	last_result=-1
	while [ $keep_running ] ; do
		output=`docker exec "$CONTAINER_NAME" /usr/local/bin/f5fpc -i`
		result=$?
		case $result in
			0) # Everything seems to be ok
				;;
			1)
				if [ "$last_result" != "1" ] ; then
					echo "Session initialized"
				fi
				;;
			2)
				if [ "$last_result" != "2" ] ; then
					echo "User login in progress"
				fi
				;;
			3)
				if [ "$last_result" != "3" ] ; then
					echo "Waiting..."
				fi
				;;
			5)
				if [ "$last_result" != "5" ] ; then
					echo "Connection established successfully"
	                dockerip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME`
	                for network in ${NETWORKS[@]} ; do
		                sudo ip route add $network via $dockerip
	                done
				fi
				;;
			7)
				echo "Logon denied"
				echo "$output"
				echo "Shutting down..."
				docker stop "$CONTAINER_NAME"
				echo ""
				exit
				;;
			9)
				echo "Connection timed out"
				echo "Shutting down..."
				docker stop "$CONTAINER_NAME"
				echo ""
				exit
				;;
			85) # client not connected
				exit
				;;
			*)
				echo "Unknown result code: $result"
				echo "Please create an issue with this code here:"
				echo "https://github.com/MatthiasLohr/docker-f5fpc/issues/new"
				echo ""
				echo "Additional information:"
				echo "$output"
				;;
		esac
		last_result="$result"
	done
}

start_client() {
	docker run -d --rm --privileged \
		--name "$CONTAINER_NAME" \
		--net host \
		-e VPNHOST="$VPNHOST" \
		-e USERNAME="$USERNAME" \
		-e PASSWORD="$PASSWORD" \
		$IMAGE_NAME \
		/opt/idle.sh > /dev/null
	if [ "$?" != 0 ] ; then
		echo "Error starting docker container."
		exit 1
	fi
	docker exec -it "$CONTAINER_NAME" /opt/connect.sh
	observe_f5fpc
}

start_gateway() {
	docker run -d --rm --privileged \
		--name "$CONTAINER_NAME" \
		--sysctl net.ipv4.ip_forward=1 \
		-e VPNHOST="$VPNHOST" \
		-e USERNAME="$USERNAME" \
		-e PASSWORD="$PASSWORD" \
		$IMAGE_NAME \
		/opt/idle.sh > /dev/null
	if [ "$?" != 0 ] ; then
		echo "Error starting docker container."
		exit 1
	fi
	docker exec -it "$CONTAINER_NAME" /opt/connect.sh
	observe_f5fpc
}

stop_vpn() {
	echo "Shutting down..."
	dockerip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME`
        for network in ${NETWORKS[@]} ; do
                ip route del $network via $dockerip
        done
	docker exec "$CONTAINER_NAME" /usr/local/bin/f5fpc -o > /dev/null
	docker stop "$CONTAINER_NAME"
	exit
}

read_routes() {
    if [ ! -f $F5FPC_HOME/routes.config ]; then
        echo No routes created. $F5FPC_HOME/routes.config does not exists.
    else
        readarray -t routes < $F5FPC_HOME/routes.config
        for route in ${routes[@]}; do
            if [[ $route =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
                NETWORKS+=("$route")
            fi
        done
    fi
}

docker_image() {
    imageid=$(docker images $IMAGE_NAME -q)
    if [ -z "$imageid" ]; then
        docker build -t $IMAGE_NAME .
    fi
}

# read CLI parameters
POSITIONAL=()
read_routes
while [ $# -gt 0 ] ; do
	case $1 in
		-h|--help)
			show_help
			exit
			shift
			;;
		-t|--host)
			VPNHOST="$2"
			shift
			shift
			;;
		-u|--user)
			USERNAME="$2"
			shift
			shift
			;;
		-p|--password)
			PASSWORD="$2"
			shift
			shift
			;;
		*)
			POSITIONAL+=("$1")
			shift
			;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# start vpn connection
trap stop_vpn INT
MODE="$1"

if [ -z "$MODE" ] ;  then
	echo "No mode given!"
	show_help
	exit 1
fi

docker_image
case $MODE in
	client)
		start_client
		;;
	gateway)
		start_gateway
		;;
	*)
		echo "Unsupported mode $MODE!"
		show_help
		exit 1
		;;
esac

