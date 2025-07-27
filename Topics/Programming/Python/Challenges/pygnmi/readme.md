# Pygnmi
The idea behind pyGNMI is simple. That is a Python package, which you can use in your code to interact with the network functions using the gNMI. There is a number of issue we would need to solve during the development:

* implementation of both secure and insecure gRPC channels
* implementation of all RPCs (Capabilities, Get, Set, Subscribe) in a way it is easy to use them
* implementation of all options and arguments, but, again, it should be easy and convenient to use them

## Challenges 
We have multiple challenges for pygnmi for [Arista ceos](/Topics/Programming/Python/Challenges/pygnmi/Arista) and [Nokia SRLinux ](/Topics/Programming/Python/Challenges/pygnmi/Nokia) Routers

## Arista ceos
| Day | Description |
| ----- | ------ |
| Day 01 | [Getting Started with Containerlab and `pygnmi` Capabilities](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-01.md) | 
| Day 02 | [Reading Operational Data with gNMI Get](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-02.md) | 
| Day 03 | [Configuring Devices with gNMI Set (Update/Replace)](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-03.md) | 
| Day 04 | [Deleting Configuration with gNMI Set (Delete)](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-04.md) | 
| Day 05 | [Streaming Telemetry with gNMI Subscribe](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-05.md) | 
| Day 06 | [Advanced Topics - Error Handling and Custom YANG Paths](/Topics/Programming/Python/Challenges/pygnmi/Arista/Day-06.md) | 

## Nokia SR Linux
| Day | Description | State |
| ----- | ------ | ------ |
| Day 01 | [Getting Started with Containerlab and `pygnmi` Capabilities](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-01.md) | working |
| Day 02 | [Reading Operational Data with gNMI Get](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-02.md) | working |
| Day 03 | [Configuring Devices with gNMI Set (Update/Replace)](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-03.md) | working |
| Day 04 | [Deleting Configuration with gNMI Set (Delete)](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-04.md) | working |
| Day 05 | [Streaming Telemetry with gNMI Subscribe](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-05.md) | working |
| Day 06 | [Advanced Topics - Error Handling and Custom YANG Paths](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-06.md) | working |
| Day 07 | [Comprehensive Automation Scenario and Cleanup](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-07.md) | not working to far |
| Day 08 | [Configuration Backup and Restore](/Topics/Programming/Python/Challenges/pygnmi/Nokia/Day-08.md) | untested |

## Sources
* https://pypi.org/project/pygnmi/0.2.5/
* https://github.com/nokia/pygnmi
* https://karneliuk.com/2020/10/pygnmi-2-how-to-use-pygnmi/
* https://www.youtube.com/playlist?list=PLsTgo2tBPnTwmeP9zsd8B_tZR-kbguvla