#!/bin/bash
#

# JOB_CONF_FILE is a file of Okuyama Node definition
readonly JOB_CONF_FILE="/home/okuyama/conf/MasterNode.properties"

##
# Make dataNode array and update properties
#
readonly DATANODE_NAMES=$(env | grep -E "^OKUYAMA_DATANODE(_[0-9]+)?_PORT_5553_TCP=" | cut -d= -f1 | sort | uniq)
if [ -z "$DATANODE_NAMES" ]; then
	echo >&2 'error: missing OKUYAMA_DATANODE_<num>_PORT_5553_TCP environment variable'
	echo >&2 '  Did you forget to --link some_okuyama-datanode_container:okuyama-datanode_1 and so on?'
	exit 1
fi
echo $DATANODE_NAMES

DATANODE_ARRAY=""
DATANODE_COUNT=0
for i in $DATANODE_NAMES; do
  eval TCP="$"${i}
  DATANODE_COUNT=`expr $DATANODE_COUNT + 1`
  DATANODE_ARRAY=$DATANODE_ARRAY,${TCP##tcp://}
done
DATANODE_ARRAY=${DATANODE_ARRAY#,}
echo $DATANODE_ARRAY

sed -i "s/^KeyMapNodesRule=.*/KeyMapNodesRule=$DATANODE_COUNT/" $JOB_CONF_FILE
sed -i "s/^KeyMapNodesInfo=.*/KeyMapNodesInfo=$DATANODE_ARRAY/" $JOB_CONF_FILE

##
# Make dataNode mirror array and update properties
#
readonly DATANODE_MIRROR_NAMES=$(env | grep -E "^OKUYAMA_DATANODE_MIRROR(_[0-9]+)?_PORT_5553_TCP=" | cut -d= -f1 | sort | uniq)
if [ -n "$DATANODE_MIRROR_NAMES" ]; then
  ## Make dataNode array and update properties
  DATANODE_MIRROR_ARRAY=""
  DATANODE_MIRROR_COUNT=0
  for i in $DATANODE_MIRROR_NAMES; do
    eval TCP="$"${i}
    DATANODE_MIRROR_COUNT=`expr $DATANODE_MIRROR_COUNT + 1`
    DATANODE_MIRROR_ARRAY=$DATANODE_MIRROR_ARRAY,${TCP##tcp://}
  done
  echo $DATANODE_MIRROR_ARRAY

  ##
  if [ $DATANODE_MIRROR_COUNT -ne $DATANODE_COUNT ]; then
	echo >&2 'error: unmatch counts of OKUYAMA_DATANODE and OKUYAMA_DATANODE_MIRROR'
	exit 1
  fi
  DATANODE_MIRROR_ARRAY=${DATANODE_MIRROR_ARRAY#,}
  sed -i "s/^SubKeyMapNodesInfo=.*/SubKeyMapNodesInfo=$DATANODE_ARRAY/" $JOB_CONF_FILE
fi


## DEFAULT SETTINGS
readonly DEFAULT_OKUYAMA_HOME="/home/okuyama"
readonly DEFAULT_MEM_OPTS="-Xmx216m -Xms128m -Xmn64m"
readonly DEFAULT_GC_OPTS="-XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseParNewGC -XX:TargetSurvivorRatio=98 -XX:MaxTenuringThreshold=15"

trap "stop; exit" TERM INT

start() {
	OKUYAMA_HOME="${OKUYAMA_HOME:=$DEFAULT_OKUYAMA_HOME}"
	MEM_OPTS="${MEM_OPTS:=$DEFAULT_MEM_OPTS}"
	GC_OPTS="${GC_OPTS:=$DEFAULT_GC_OPTS}"

	readonly BATCH_CONF_FILE=${OKUYAMA_HOME}/conf/Main.properties

	## Find latest Okuyama jar
	OKUYAMA_LATEST_JAR=$(ls -t ${OKUYAMA_HOME}/bin/okuyama*.jar | head -n1)
	OKUYAMA_JAR=${OKUYAMA_JAR:=$OKUYAMA_LATEST_JAR}

	## Collect jar dependencies to classpath
	CLASSPATH=$OKUYAMA_JAR:`echo $(ls ${OKUYAMA_HOME}/lib/*.jar) | sed -e 's/ /:/g'`

	#DEBUG_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
	JAVA_OPTS="-server -cp $CLASSPATH $MEM_OPTS $GC_OPTS $DEBUG_OPTS -Djava.net.preferIPv4Stack=true"

	set -x
	java -DMARK=$JOB_CONF_FILE $JAVA_OPTS okuyama.base.JavaMain $BATCH_CONF_FILE $JOB_CONF_FILE $OKUYAMA_OPTS &
	set +x

	# Run as non-demonize, but be able to gracefully shutdown by SIGTERM
	#  see http://veithen.github.io/2014/11/16/sigterm-propagation.html
	PID=$!
	wait $PID
	trap - TERM INT
	wait $PID
	EXIT_STATUS=$?
}

stop() {
	echo "stopping okuyama"
		## Extract control port of Okuyama server 
	##  ServerControllerHelper.Init=18888
	readonly OKUYAMA_CTRL_PORT=$(sed -n -e '/ServerControllerHelper.Init/{s/^.*=\s*\(\d*\)\D*/\1/;p}' $JOB_CONF_FILE)
	if [ "x$OKUYAMA_CTRL_PORT" = "x" ];then
	  echo "error: \"ServerControllerHelper.Init\" is not defined in $JOB_CONF_FILE"
	  exit 1
	fi

	## Connect control port of Okuyama server 
	exec 5<>/dev/tcp/127.0.0.1/$OKUYAMA_CTRL_PORT || {
	  echo "error: cannot connect 127.0.0.1:$OKUYAMA_CTRL_PORT"
	  exit 1
	}
	echo -e "shutdown" >&5 && {
	#  cat <&5
	  sleep 2
	  echo -e "stop" >&5
	  echo "echo stop $?"
	  cat <&5
	}
}

start
