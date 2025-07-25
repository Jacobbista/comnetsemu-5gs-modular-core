#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import os

from comnetsemu.cli import CLI
from comnetsemu.net import Containernet
from mininet.link import TCLink
from mininet.log import info, setLogLevel
from mininet.node import Controller
from python_modules.Open5GS import Open5GS
import json

if __name__ == "__main__":

    AUTOTEST_MODE = os.environ.get("COMNETSEMU_AUTOTEST_MODE", 0)

    setLogLevel("info")

    # Ottieni il percorso del file di script Python corrente
    script_path = os.path.abspath(__file__)

    # Ottieni il percorso della directory genitore del file di script
    prj_folder = os.path.dirname(script_path)

    mongodb_folder="/home/vagrant/mongodbdata"

    env = dict()

    net = Containernet(controller=Controller, link=TCLink)

    info("*** Adding Host for open5gs CP\n")

    info("*** Adding Host for open5gs MongoDB\n")
    env["COMPONENT_NAME"]="mongo"
    env["HEALTH_CHECK_TYPE"]="mongo"
    mongo = net.addDockerHost(
        "mongo",
        dimage="my5gc_v2-7-5",
        ip="192.168.0.200/24",
        dcmd="bash /open5gs/install/scripts/mongo_webui_init.sh",
        docker_args={
            "environment": env,
            "ports" : { "3000/tcp": 3000 },
            "volumes": {
                prj_folder + "/log": {
                    "bind": "/open5gs/install/var/log/open5gs",
                    "mode": "rw",
                },
                mongodb_folder: {
                    "bind": "/var/lib/mongodb",
                    "mode": "rw",
                },
                prj_folder + "/open5gs/config": {
                    "bind": "/open5gs/install/etc/open5gs",
                    "mode": "rw",
                },
                prj_folder + "/open5gs/scripts": {
                    "bind": "/open5gs/install/scripts",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
            },
        },
    )

    nf_map = {
        "nrf": {
            "ip": "192.168.0.210",
            "depends_on": None,
            "init_script": "nrf_init.sh"
        },
        "smf": {
            "ip": "192.168.0.211",
            "depends_on": "nrf",
            "init_script": "smf_init.sh"
        },
        "amf": {
            "ip": "192.168.0.212",
            "depends_on": "smf",
            "init_script": "amf_init.sh"
        },
        "ausf": {
            "ip": "192.168.0.213",
            "depends_on": "amf",
            "init_script": "ausf_init.sh"
            },
        "udm": {
            "ip": "192.168.0.214",
            "depends_on": "amf",
            "init_script": "udm_init.sh"
        },
        "udr": {
            "ip": "192.168.0.215",
            "depends_on": "amf",
            "init_script": "udr_init.sh"
        },
        "pcf": {
            "ip": "192.168.0.216",
            "depends_on": "amf",
            "init_script": "pcf_init.sh"
        },
        "bsf": {
            "ip": "192.168.0.217",
            "depends_on": "amf",
            "init_script": "bsf_init.sh"
        },
        "nssf": {
            "ip": "192.168.0.218",
            "depends_on": "amf",
            "init_script": "nssf_init.sh"
        }
    }

    extra_hosts = {
        nf_name: nf_info["ip"] for nf_name, nf_info in nf_map.items()
    }
    extra_hosts["mongo"] = "192.168.0.200"

    for nf_name, nf_info in nf_map.items():
        nf_ip = nf_info["ip"]
        nf_script = nf_info["init_script"]

        info(f"*** Adding {nf_name.upper()} to the network\n")
        env["COMPONENT_NAME"]=nf_name
        env["STATIC_IP"]=nf_ip
        env["HEALTH_CHECK_TYPE"]="nf"
        net.addDockerHost(
            nf_name,
            dimage="my5gc_v2-7-5",
            ip=f"{nf_ip}/24",
            dcmd=f"bash /open5gs/install/scripts/{nf_script}",
            docker_args={
                "environment": env,
                "extra_hosts" : extra_hosts,
                "volumes": {
                    prj_folder + "/log": {
                        "bind": "/open5gs/install/var/log/open5gs",
                        "mode": "rw",
                    },
                    prj_folder + "/open5gs/config": {
                        "bind": "/open5gs/install/etc/open5gs",
                        "mode": "rw",
                    },
                    prj_folder + "/open5gs/scripts": {
                        "bind": "/open5gs/install/scripts",
                        "mode": "rw",
                    },
                    "/etc/timezone": {
                        "bind": "/etc/timezone",
                        "mode": "ro",
                    },
                    "/etc/localtime": {
                        "bind": "/etc/localtime",
                        "mode": "ro",
                    },
                },
            },
        )


    info("*** Adding Host for open5gs UPF\n")
    env["COMPONENT_NAME"]="upf_cld"
    env["HEALTH_CHECK_TYPE"]="upf"
    upf_cld = net.addDockerHost(
        "upf_cld",
        dimage="my5gc_v2-7-5",
        ip="192.168.0.112/24",
        dcmd="bash /open5gs/install/etc/open5gs/temp/5gc_up_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/log": {
                    "bind": "/open5gs/install/var/log/open5gs",
                    "mode": "rw",
                },
                prj_folder + "/open5gs/config": {
                    "bind": "/open5gs/install/etc/open5gs/temp",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
            },
            "cap_add": ["NET_ADMIN"],
            "sysctls": {"net.ipv4.ip_forward": 1},
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        }, 
    )

    info("*** Adding Host for open5gs UPF MEC\n")
    env["COMPONENT_NAME"]="upf_mec"
    env["HEALTH_CHECK_TYPE"]="upf"
    upf_mec = net.addDockerHost(
        "upf_mec",
        dimage="my5gc_v2-7-5",
        ip="192.168.0.113/24",
        dcmd="bash /open5gs/install/etc/open5gs/temp/5gc_up_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/log": {
                    "bind": "/open5gs/install/var/log/open5gs",
                    "mode": "rw",
                },
                prj_folder + "/open5gs/config": {
                    "bind": "/open5gs/install/etc/open5gs/temp",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
            },
            "cap_add": ["NET_ADMIN"],
            "sysctls": {"net.ipv4.ip_forward": 1},
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        },
    )

    info("*** Adding gNB 1\n")
    env["COMPONENT_NAME"]="gnb1"
    gnb1 = net.addDockerHost(
        "gnb1", 
        dimage="myueransim_v3-2-7",
        ip="192.168.0.131/24",
        dcmd="bash /mnt/ueransim/open5gs_gnb_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/ueransim/config": {
                    "bind": "/mnt/ueransim",
                    "mode": "rw",
                },
                prj_folder + "/log": {
                    "bind": "/mnt/log",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
                "/dev": {"bind": "/dev", "mode": "rw"},
            },
            "cap_add": ["NET_ADMIN"],
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        },
    )
    
    info("*** Adding gNB 2\n")
    env["COMPONENT_NAME"]="gnb2"
    gnb2 = net.addDockerHost(
        "gnb2", 
        dimage="myueransim_v3-2-7",
        ip="192.168.0.132/24",
        dcmd="bash /mnt/ueransim/open5gs_gnb_2_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/ueransim/config": {
                    "bind": "/mnt/ueransim",
                    "mode": "rw",
                },
                prj_folder + "/log": {
                    "bind": "/mnt/log",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
                "/dev": {"bind": "/dev", "mode": "rw"},
            },
            "cap_add": ["NET_ADMIN"],
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        },
    )

    info("*** Adding UE1\n")
    env["COMPONENT_NAME"]="ue1"
    ue1 = net.addDockerHost(
        "ue1", 
        dimage="myueransim_v3-2-7",
        ip="192.168.0.133/24",
        dcmd="bash /mnt/ueransim/open5gs_ue_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/ueransim/config": {
                    "bind": "/mnt/ueransim",
                    "mode": "rw",
                },
                prj_folder + "/log": {
                    "bind": "/mnt/log",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
                "/dev": {"bind": "/dev", "mode": "rw"},
            },
            "cap_add": ["NET_ADMIN"],
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        },
    )
    
    info("*** Adding UE2\n")
    env["COMPONENT_NAME"]="ue2"
    ue2 = net.addDockerHost(
        "ue2", 
        dimage="myueransim_v3-2-7",
        ip="192.168.0.134/24",
        dcmd="bash /mnt/ueransim/open5gs_ue_2_init.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/ueransim/config": {
                    "bind": "/mnt/ueransim",
                    "mode": "rw",
                },
                prj_folder + "/log": {
                    "bind": "/mnt/log",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
                "/dev": {"bind": "/dev", "mode": "rw"},
            },
            "cap_add": ["NET_ADMIN"],
            "devices": "/dev/net/tun:/dev/net/tun:rwm"
        },
    )
    
    info("*** Adding MEC SERVER\n")
    env["COMPONENT_NAME"]="mec_server"
    mec_server = net.addDockerHost(
        "mec_server", 
        dimage="mec_server",
        ip="192.168.0.135/24",
        dcmd="bash /mnt/mec_server/mec_server.sh",
        docker_args={
            "environment": env,
            "volumes": {
                prj_folder + "/mec_server": {
                    "bind": "/mnt/mec_server",
                    "mode": "rw",
                },
                prj_folder + "/log": {
                    "bind": "/mnt/log",
                    "mode": "rw",
                },
                "/etc/timezone": {
                    "bind": "/etc/timezone",
                    "mode": "ro",
                },
                "/etc/localtime": {
                    "bind": "/etc/localtime",
                    "mode": "ro",
                },
            },
            "cap_add": ["NET_ADMIN"],
        },
    )

    info("*** Add controller\n")
    net.addController("c0")

    info("*** Adding switch\n")
    s1 = net.addSwitch("s1")
    s2 = net.addSwitch("s2")
    s3 = net.addSwitch("s3")

    info("*** Adding links\n")
    net.addLink(s1,  s2, bw=1000, delay="10ms", intfName1="s1-s2",  intfName2="s2-s1")
    net.addLink(s2,  s3, bw=1000, delay="50ms", intfName1="s2-s3",  intfName2="s3-s2")
    
    net.addLink(mongo,      s3, bw=1000, delay="1ms", intfName1="mongo-s3",  intfName2="s3-mongo")
    # Add a link from each NF to s3
    for nf_name in nf_map.keys():
        net.addLink(nf_name, s3, bw=1000, delay="1ms", intfName1=f"{nf_name}-s3", intfName2=f"s3-{nf_name}")

    net.addLink(upf_cld, s3, bw=1000, delay="1ms", intfName1="upf-s3",  intfName2="s3-upf")
    net.addLink(upf_mec, s2, bw=1000, delay="1ms", intfName1="upf_mec-s2", intfName2="s2-upf_mec")

    net.addLink(ue1,  s1, bw=1000, delay="1ms", intfName1="ue1-s1",  intfName2="s1-ue1")
    net.addLink(ue2,  s1, bw=1000, delay="1ms", intfName1="ue2-s1",  intfName2="s1-ue2")
    net.addLink(gnb1, s1, bw=1000, delay="1ms", intfName1="gnb1-s1", intfName2="s1-gnb1")
    net.addLink(gnb2, s1, bw=1000, delay="1ms", intfName1="gnb2-s1", intfName2="s1-gnb2")
    
    net.addLink(mec_server, s2, bw=1000, delay="5ms", intfName1="mec_server-s2", intfName2="s2-mec_server")
    
    print("\n*** Open5GS: Starting subscription procedure")
    o5gs   = Open5GS( "172.17.0.2" ,"27017")
    o5gs.removeAllSubscribers()
    with open( prj_folder + "/python_modules/subscriber_profile2_2.json" , 'r') as f:
        data = json.load( f )

    if "subscribers" in data:
        subscribers = data["subscribers"]
        n = 0
        for subscriber in subscribers:
            n += 1
            o5gs.addSubscriber(subscriber)
        info(f"*** Open5GS: Successfuly added {n} subscribers ")
    else:
        info(f"*** Open5GS: No subscribers found")
    
    

    info("\n*** Starting network\n")
    net.start()

    if not AUTOTEST_MODE:
        # spawnXtermDocker("open5gs")
        CLI(net)
    net.stop()
