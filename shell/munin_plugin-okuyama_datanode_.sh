#!/bin/bash
#
# Wildcard-script to monitor Okuyama KVS datanode. To monitor an
# datanode, link okuyama_datanode_<port> to this file. E.g.
#
#    ln /usr/share/munin/plugins/okuyama_datanode_ /etc/munin/plugins/okuyama_datanode_5553
#
# ...will monitor Okuyama DataNode listning on port 5553
#
# Parameters:
#
# 	config
#
#%# family=manual

HOST=localhost
PORT=$(basename $0 | sed 's/^okuyama_datanode_//g')

RETVAL=0

case "$1" in
config)
  echo "graph_order jvm_max jvm_total jvm_in_use save_data_size" 
  echo "graph_title Okuyama KVS DataNode Memory Usage port:$PORT"
  echo 'graph_args --right-axis 0.00001:0 --right-axis-label count'
  echo 'graph_vlabel bytes'
  #echo 'graph_period minute'
  echo 'graph_category datastore'
  echo 'jvm_max.label jvm_max'
  echo 'jvm_max.min 0'
  echo 'jvm_max.max 1000000000'
  #echo 'jvm_max.graph no'
  echo 'jvm_max.draw AREA'
  echo 'jvm_total.label jvm_total'
  echo 'jvm_total.min 0'
  echo 'jvm_total.max 1000000000'
  echo 'jvm_total.draw AREA'
  echo 'jvm_free.graph no'
  echo 'jvm_in_use.label jvm_in_use'
  echo 'jvm_in_use.cdef jvm_total,jvm_free,-'
  echo 'jvm_in_use.draw AREA'
  echo 'save_data_size.label data_size'
  echo 'save_data_size.min 0'
  echo 'save_data_size.draw AREA'
  echo 'save_data_count.graph no'
#  echo 'save_data_count.label data_count'
#  echo 'save_data_count.min 0'
#  echo 'save_data_count.draw LINE'
  ;;
*)
  #awk "/bytes received/ { print \"received.value \" \$4 } /bytes transmitted/ { print \"transmitted.value \" \$4 }" < /proc/net/vlan/$INTERFACE
  ## 10,true,JVM MaxMemory Size =[127];JVM TotalMemory Size =[127]; JVM FreeMemory Size =[90]; JVM Use Memory Percent=[29];Save Data Count=[0];Last Data Change Time=[0];Save Data Size=[all=141]
  ## jvm_max.value 127000000
  ## jvm_total.value 127000000
  ## jvm_free.value 90000000
  ## save_data_count.value 3
  ## save_data_size.value 141
  (exec 5<>/dev/tcp/$HOST/$PORT && {
    echo -e 10 >&5
    head -n1 <&5 \
    |tr A-Z a-z \
    |sed -E 's/^10,true,//;s/; */'\\$'\n''/g; s/\]//g; s/ +/_/g; s/_*=\[/.value /g; s/all=|memory_size//g;' \
    |awk '/^jvm_(max|total|free)/{print $1 " " $2*1000000 };/^save_data/{print $0}'
  }) 2> /dev/null;
  ;;
esac
exit $RETVAL
