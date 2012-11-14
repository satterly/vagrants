#!/usr/bin/env python
########################################
#
# redis.py - Ganglia module for redis
#
########################################

# Metrics
#########
#  redis_version            redis_version
#  redis_uptime             redis_uptime
#  redis_conns_clients      connected_clients
#  redis_conns_slaves       connected_slaves
# *redis_conns_rate         total_connections_received
#  redis_blocked_clients    blocked_clients
#  redis_cpu_system         used_cpu_sys
#  redis_cpu_user           used_cpu_user
#  redis_mem_virt           used_memory
#  redis_mem_rss            used_memory_rss
#  redis_mem_fragment       mem_fragmentation_ratio (used_memory / used_memory_rss)
# *redis_command_rate       total_commands_processed
# *redis_expire_rate        expired_keys
# *redis_evict_rate         evicted_keys
# *redis_hit_rate           keyspace_hits
# *redis_miss_rate          keyspace_misses
# *redis_hit_ratio          keyspace_hits & keyspace_misses
#  redis_role               role

# * = derived metric

import os
import sys
import threading
import time
import socket
import select

_WorkerThread = None		# Worker thread object
_Lock = threading.Lock()	# Synchronization lock
_refresh_rate = 15		# Refresh rate of the data

_host = 'localhost'
_port = 6379

Version = "1.0.1 14/11/2012"
Debug = False

def dprint(f, *v):
    if Debug:
        print >>sys.stderr, "DEBUG: "+f % v

class UpdateMetricThread(threading.Thread):

    def __init__(self):
        threading.Thread.__init__(self)
        self.running      = False
        self.shuttingdown = False

        self.metric        = {}
        self.last_metric   = {}
        self.timeout       = 2

    def shutdown(self):
        self.shuttingdown = True
        if not self.running:
            return
        self.join()

    def run(self):
        global _refresh_rate
        self.running = True

        while not self.shuttingdown:
            _Lock.acquire()
            self.update_metric()
            _Lock.release()

            time.sleep(_refresh_rate)

        self.running = False

    def update_metric(self):
        global _host, _port
        self.last_metric = self.metric.copy()

        for d in _descriptors:
            self.metric[d['name']] = 0.0 # initialias values

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        msg = ""
        try:
            dprint("Connecting to %s:%d", _host, _port)
            sock.connect((_host, _port))
            sock.send('INFO\r\nQUIT\r\n')

            msg = ''
            while True:
                data = sock.recv(4096)
                if not data:
                    break
                msg += data
            sock.close()

        except socket.error, e:
            print >>sys.stderr, "ERROR: %s" % e

        for m in msg.split("\r\n"):
            if not m.strip():                            # skip empty lines
                continue
            if m[0] == "#":
                continue
            d = m.split(":")
            if d[0] == "redis_version":
                self.metric['redis_version'] = d[1]
            elif d[0] == "uptime_in_seconds":
                self.metric['redis_uptime'] = int(d[1])
            elif d[0] == "connected_clients":
                self.metric['redis_conns_clients'] = int(d[1])
            elif d[0] == "connected_slaves":
                self.metric['redis_conns_slaves'] = int(d[1])
            elif d[0] == "total_connections_received":
                self.metric['redis_conns_rate'] = int(d[1])
            elif d[0] == "blocked_clients":
                self.metric['redis_blocked_clients'] = int(d[1])
            elif d[0] == "used_cpu_sys":
                self.metric['redis_cpu_system'] = float(d[1])
            elif d[0] == "used_cpu_user":
                self.metric['redis_cpu_user'] = float(d[1])
            elif d[0] == "used_memory":
                self.metric['redis_mem_virt'] = int(d[1])
            elif d[0] == "used_memory_rss":
                self.metric['redis_mem_rss'] = int(d[1])
            elif d[0] == "mem_fragmentation_ratio":
                self.metric['redis_mem_fragment'] = float(d[1])
            elif d[0] == "total_commands_processed":
                self.metric['redis_command_rate'] = float(d[1])
            elif d[0] == "expired_keys":
                self.metric['redis_expire_rate'] = float(d[1])
            elif d[0] == "evicted_keys":
                self.metric['redis_evict_rate'] = float(d[1])
            elif d[0] == "keyspace_hits":
                self.metric['redis_hit_rate'] = float(d[1])
            elif d[0] == "keyspace_misses":
                self.metric['redis_miss_rate'] = float(d[1])
            elif d[0] == "role":
                self.metric['redis_role'] = d[1]

            self.metric['redis_time'] = time.time()

        dprint("%s", self.metric)

    def metric_of(self, name):
        val = 0

        if name.endswith('_rate'):
            if name in self.last_metric and self.metric[name] > self.last_metric[name]:
                _Lock.acquire()
                # dprint('num %d - %d = %d', self.metric[name], self.last_metric[name], self.metric[name] - self.last_metric[name])
                num = self.metric[name] - self.last_metric[name]
                # dprint('period %d - %d = %d', self.metric['redis_time'], self.last_metric['redis_time'], self.metric['redis_time'] - self.last_metric['redis_time'])
                period = self.metric['redis_time'] - self.last_metric['redis_time']
                try:
                    val = 1.0 * num/period
                except ZeroDivisionError:
                    val = 0.0
                _Lock.release()
        elif name == 'redis_hit_ratio':
            if name in self.last_metric and self.metric['redis_hit_rate'] > self.last_metric['redis_hit_rate']:
                _Lock.acquire()
                num = self.metric['redis_hit_rate'] - self.last_metric['redis_hit_rate']
                total = ((self.metric['redis_hit_rate'] + self.metric['redis_miss_rate']) - 
                         (self.last_metric['redis_hit_rate'] + self.last_metric['redis_miss_rate']))
                try:
                    val = (1.0 * num/total) * 100.0
                except ZeroDivisionError:
                    val = 0.0
                _Lock.release()
        elif name in self.metric:
            # dprint('%s= %s', name, self.metric[name])
            _Lock.acquire()
            val = self.metric[name]
            _Lock.release()
    
        return val

def redis_stats(name):
    global _WorkerThread

    if _WorkerThread is None:
        print >>sys.stderr, "ERROR: No data gathering thread created for metric %s" % name
        return 0

    if not _WorkerThread.running and not _WorkerThread.shuttingdown:
        try:
            _WorkerThread.start()
        except (AssertionError, RuntimeError):
            pass

    return _WorkerThread.metric_of(name)

# Metric descriptions
_descriptors = [
    {
        'name': 'redis_version',
        'call_back': redis_stats,
        'time_max': 60,
        'units': '',
        'slope': 'zero',
        'value_type': 'string',
        'format': '%s',
        'description': 'Redis version',
        'groups': 'redis',
    },
    {
        'name': 'redis_uptime',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'uptime',
        'slope': 'zero',
        'value_type': 'uint', 
        'format': '%d',
        'description': 'Number of seconds since redis started.',
        'groups': 'redis',
    },
    {
        'name': 'redis_conns_clients',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'connections',
        'slope': 'both',
        'value_type': 'uint',
        'format': '%d',
        'description': 'Number of client connections',
        'groups': 'redis',
    },
    {
        'name': 'redis_conns_slaves',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'connections',
        'slope': 'both',
        'value_type': 'uint',
        'format': '%d',
        'description': 'Number of slave connections',
        'groups': 'redis',
    },
    {
        'name': 'redis_conns_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'connections/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of connections opened per second.',
        'groups': 'redis',
    },
    {
        'name': 'redis_blocked_clients',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'blocked',
        'slope': 'both',
        'value_type': 'uint',
        'format': '%d',
        'description': 'Number of blocked clients',
        'groups': 'redis',
    },
    {
        'name': 'redis_cpu_system',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'percent',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'System CPU consumed by Redis server',
        'groups': 'redis',
    },
    {
        'name': 'redis_cpu_user',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'percent',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'User CPU consumed by Redis server',
        'groups': 'redis',
    },
    {
        'name': 'redis_mem_virt',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'bytes',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': ' by Redis server',
        'groups': 'redis',
    },
    {
        'name': 'redis_mem_rss',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'bytes',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': ' by Redis server',
        'groups': 'redis',
    },
    {
        'name': 'redis_mem_fragment',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'bytes',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Ratio of resident set size to used memory',
        'groups': 'redis',
    },
    {
        'name': 'redis_command_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'commands/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of commands per second',
        'groups': 'redis',
    },
    {
        'name': 'redis_expire_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'expired keys/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of keys expired per second',
        'groups': 'redis',
    },
    {
        'name': 'redis_evict_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'evicted keys/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of keys evicted per second',
        'groups': 'redis',
    },
    {
        'name': 'redis_hit_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'hits/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of keys that have been requested and found present per second.',
        'groups': 'redis',
    },
    {
        'name': 'redis_miss_rate',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'misses/s',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'Number of keys that have been requested and not found per second.',
        'groups': 'redis',
    },
    {
        'name': 'redis_hit_ratio',
        'call_back': redis_stats,
        'time_max': 60,
        'units': 'percent',
        'slope': 'both',
        'value_type': 'float',
        'format': '%.2f',
        'description': 'The ratio of hits as percentage of all keyspace commands for the interval.',
        'groups': 'redis',
    },
    {
        'name': 'redis_role',
        'call_back': redis_stats,
        'time_max': 60,
        'units': '',
        'slope': 'zero',
        'value_type': 'string',
        'format': '%s',
        'description': 'Redis server role',
        'groups': 'redis',
    }
]

def metric_init(params):
    global _descriptors, _refresh_rate, _host, _port, _WorkerThread, Debug

    print '[redis] Initialising redis metric module (v%s)' % Version

    if 'Debug' in params:
        Debug = str(params.get('Debug', False)) == "True"
    dprint("%s", "Debug mode on")
    dprint("%s", params)

    if 'RefreshRate' in params:
        _refresh_rate = int(params['RefreshRate'])

    if 'Host' in params:
        _host = params['Host']

    if 'Port' in params:
        _port = int(params['Port'])

    _WorkerThread = UpdateMetricThread()
    
    return _descriptors

def metric_cleanup():
    _WorkerThread.shutdown()

if __name__ == '__main__':
    params = { 'Host' : 'localhost', 'Port' : '6379', 'RefreshRate': '20', 'Debug' : True }
    metric_init(params)
    while True:
        try:
            for d in _descriptors:
                v = d['call_back'](d['name'])
                print ('value for %s is '+d['format']+' %s') % (d['name'], v, d['units'])
            time.sleep(5)
        except KeyboardInterrupt:
            time.sleep(0.2)
            os._exit(1)
