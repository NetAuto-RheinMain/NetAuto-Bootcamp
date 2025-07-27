# Nornir
Nornir is an automation framework written in python to be used with python. Most automation frameworks hide the language they are written in by using some cumbersome pseudo-language which usually is almost Turing complete, but lacks tooling to debug and troubleshoot. Integrating with other systems is also usually quite hard as they usually have complex APIs if any at all. Some of the other common problems of those pseudo-languages is that are usually quite bad at dealing with data and re-usability is limited.

Nornir aims to solve those problems by providing a pure python framework. Just imagine Nornir as the Flask of automation. Nornir will take care of dealing with the inventory where you have your host information, it will take care of dispatching the tasks to your devices and will provide a common framework to write “plugins”.

## **Prerequisites:**

  * **Linux Host:** A Linux machine (VM or bare metal) is highly recommended. Ubuntu is a good choice.
  * **Docker:** Containerlab relies on Docker. Ensure it's installed and running on your Linux host.
  * **Containerlab:** Install Containerlab by following the official documentation: [https://containerlab.dev/install/](https://containerlab.dev/install/)
  * **Arista cEOS Image:** You'll need to download a cEOS image from the Arista support portal. Register for a free account if you don't have one. Once downloaded, import it into Docker. For example: `docker import cEOS-lab-4.xx.xF.tar ceos:4.xx.xF` (replace `4.xx.xF` with your actual version).
  * **Python 3 & pip:** Ensure you have Python 3 and pip installed.
  * **Virtual Environment:** It's best practice to work within a Python virtual environment to manage dependencies.
  * **Basic Python knowledge:** Familiarity with Python fundamentals (variables, lists, dictionaries, functions) will be helpful.
  * **Basic Networking knowledge:** Understanding of network concepts like IP addressing, routing, and device configuration.


## Overview

| Day | Description | State |
| ------ | ----- | ----- |
| Day 01 | [Setting up the Lab Environment](/Topics/Programming/Python/Challenges/Nornir/Day-01.md) | not tested |
| Day 02 | [Nornir Fundamentals - Inventory](/Topics/Programming/Python/Challenges/Nornir/Day-02.md) | not tested |
| Day 03 | [Basic Device Interaction with Scrapli](/Topics/Programming/Python/Challenges/Nornir/Day-03.md) | not tested |
| Day 04 | [Configuration Management - Sending Commands](/Topics/Programming/Python/Challenges/Nornir/Day-04.md) | not tested |
| Day 05 | [Leveraging Jinja2 for Dynamic Configurations](/Topics/Programming/Python/Challenges/Nornir/Day-05.md) | not tested |
| Day 06 | [Advanced Inventory & Data Structures](/Topics/Programming/Python/Challenges/Nornir/Day-06.md) | not tested |
| Day 07 | [Data Validation and Error Handling](/Topics/Programming/Python/Challenges/Nornir/Day-07.md) | not tested |
| Day 08 | [Structured Data with TextFSM (Optional but Recommended)](/Topics/Programming/Python/Challenges/Nornir/Day-08.md) | not tested |
| Day 09 | [Integrating Nornir with Containerlab's Generated Inventory](/Topics/Programming/Python/Challenges/Nornir/Day-09.md) | not tested |
| Day 10 | [Building a Complete Automation Workflow & Cleanup](/Topics/Programming/Python/Challenges/Nornir/Day-10.md) | not tested |

## Sources
* https://nornir.readthedocs.io/en/latest/