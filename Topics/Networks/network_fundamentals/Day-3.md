# Switching Fundamentals & MAC/ARP
Switching is the process of transferring data packets from one device to another in a network, or from one network to another, using specific devices called switches. A computer user experiences switching all the time for example, accessing the Internet from your computer device, whenever a user requests a webpage to open, the request is processed through switching of data packets only.

Switching takes place at the Data Link layer of the OSI Model. This means that after the generation of data packets in the Physical Layer, switching is the immediate next process in data communication.

## Introduction to Switch

A switch is a hardware device in a network that connects and helps multiple devices share a network without their data interfering with each other. A switch works like a traffic cop at a busy intersection. When a data packet arrives, the switch decides where it needs to go and sends it through the right port.
Some data packets come from devices directly connected to the switch, like computers or VoIP phones. Other packets come from devices connected through hubs or routers.
The switch knows which devices are connected to it and can send data directly between them. If the data needs to go to another network, the switch sends it to a router, which forwards it to the correct destination.

The switching process involves the following steps:

Frame Reception: The switch receives a data frame or packet from a computer connected to its ports.
MAC Address Extraction: The switch reads the header of the data frame and collects the destination MAC Address from it.
MAC Address Table Lookup: Once the switch has retrieved the MAC Address, it performs a lookup in its Switching table to find a port that leads to the MAC Address of the data frame.
Forwarding Decision and Switching Table Update: If the switch matches the destination MAC Address of the frame to the MAC address in its switching table, it forwards the data frame to the respective port. However, if the destination MAC Address does not exist in its forwarding table, it follows the flooding process, in which it sends the data frame to all its ports except the one it came from and records all the MAC Addresses to which the frame was delivered. This way, the switch finds the new MAC Address and updates its forwarding table.
Frame Transition: Once the destination port is found, the switch sends the data frame to that port and forwards it to its target computer/network.

### Manageable Switch

There are 2 types of switches

The terms Layer 2 and Layer 3 are taken from the OSI model. OSI or Open System Interconnect model is a reference model that describes and explains networks communications

1. Layer 2 switch: Forwards packets on the basis of unique MAC addresses, Can quickly be deployed at a lower cost, Low latency and improved security
2. Layer 3 switch: Offers IP address based packet forwarding (routing), enables a router of connecting different subnetworks, Utilize logical addressing to find optimum paths to destination hosts or networks

#### Lets get some hands on !

Install cisco packer tracer in your system. 

Follow these steps to perform an initial switch setup. You can insert your own screenshots where indicated.

---

Launch Packet Tracer and Add a Switch

1. Open Packet Tracer.
2. From the **Switches** palette, drag a Cisco 2960 (or similar) into the workspace.

<p align="center">
  <img src="img/add_switch.png" alt="Switch tutorial">
</p>

Console into the Switch

1. From the **Connections** toolbar, select the **Console** cable (light blue).
2. Click the switch’s **Console** port, then click a PC’s **RS-232** port.
3. On the PC, open the **Terminal** and click **OK**.

<p align="center">
  <img src="img/cli_switch.png" alt="Switch tutorial">
</p>

---

Enter Privileged EXEC Mode

```
Switch> enable
Switch#
```

---

Enter Global Configuration Mode

```
Switch# configure terminal
Switch(config)#
```

---

Set a Hostname

```
Switch(config)# hostname SW1
SW1(config)#
```

---

## ARP Protcol

Address Resolution Protocol (ARP) is a protocol or procedure that connects an ever-changing Internet Protocol (IP) address to a fixed physical machine address, also known as a media access control (MAC) address, in a local-area network (LAN). 

This mapping procedure is important because the lengths of the IP and MAC addresses differ, and a translation is needed so that the systems can recognize one another. The most used IP today is IP version 4 (IPv4). An IP address is 32 bits long. However, MAC addresses are 48 bits long. ARP translates the 32-bit address to 48 and vice versa.

## References

1. GeeksforGeeks. [What is MAC (Media Access Control) Address?](https://www.geeksforgeeks.org/computer-networks/mac-address-in-computer-network/)  
2. Wikipedia. [MAC Address](https://en.wikipedia.org/wiki/MAC_address)  
3. Geography of Wikipedia. [Network Switch](https://en.wikipedia.org/wiki/Network_switch)  
4. Wikipedia. [Forwarding Information Base](https://en.wikipedia.org/wiki/Forwarding_information_base)  
5. GeeksforGeeks. [Data Link Layer](https://www.geeksforgeeks.org/computer-networks/data-link-layer/)  
6. NewRelic (Blog). [Guide to Address Resolution Protocol (ARP)](https://newrelic.com/blog/best-practices/arp-address-resolution-protocol)  
7. Wikipedia. [Address Resolution Protocol (ARP)](https://en.wikipedia.org/wiki/Address_Resolution_Protocol)  
8. Splunk (Blog). [What's ARP? Address Resolution Protocol Explained](https://www.splunk.com/en_us/blog/learn/address-resolution-protocol-arp.html)  
9. Practical Networking. [Host to Host Through a Switch](https://www.practicalnetworking.net/series/packet-traveling/host-to-host-through-a-switch/)  
10. Cisco Learning Network. [Does a Layer 2 Switch Request ARP?](https://learningnetwork.cisco.com/s/question/0D53i00000Kt6GuCAJ/does-a-layer-2-switch-requests-arp)  
