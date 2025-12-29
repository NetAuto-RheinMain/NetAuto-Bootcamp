# 🚀 NetAuto Bootcamp: Getting Started Guide

Welcome to the Network Automation Bootcamp! We use **GitHub Codespaces** to provide a consistent learning environment. This means you do **not** need to install Docker, Go, or Python on your local laptop. Everything runs directly in your browser within an isolated cloud environment.

## 📋 Prerequisites

1. A **GitHub Account**.
2. The **Arista cEOS Image file** (here you can read how to get it: [Arista cEOS](https://containerlab.dev/manual/kinds/ceos/#getting-arista-ceos-image)).

---

## 1. Launching the Environment

1. Navigate to the main page of this repository.
2. Click the green **`<> Code`** button.
3. Select the **`Codespaces`** tab.
4. Go on the three dots next to the `+` in the Codespaces line `...`
5. Click on `+ New with options ...`
6. Choose a machine type. We recommend at least `4-core` or more.
7. Click the button **`Create codespace`**.

> **☕ Patience required:** The initial startup takes about **2-4 minutes**. In the background, the system is installing Containerlab and downloading the router images (SRLinux).

Once you see the VS Code editor in your browser and the terminal at the bottom is ready, you are good to go.

---

## 2. Import Arista cEOS Image 

Since the Arista image is not public, you must manually import it into your environment once:

1. **Drag & Drop** the file `cEOS64-lab-4.30.0F.tar.xz` (or similar) into the file explorer on the left side of your Codespace window.
2. Wait for the upload to finish (check the status bar or notification).
3. Run the following command in the terminal to make the image available to Docker:

```bash
docker import cEOS64-lab-4.30.0F.tar.xz ceos:4.30.0F

```

*Note: Please adjust the filename in the command if your file version differs.*

---

## 3. Start your first Lab (Containerlab)

We use `containerlab` to spin up virtual routers. Since it creates network interfaces, we must run it with `sudo`.

**Deploy a topology:**

```bash
sudo containerlab deploy -t clab-topologies/lab01-basic.yml

```

After a few moments, you will see a table listing your routers and their management IP addresses.

**Accessing the routers:**
You can connect via SSH directly from the terminal:

```bash
# Example for SRLinux (User: admin, Pass: admin)
ssh admin@clab-bootcamp-srl1

# Example for Arista (User: admin, Pass: admin)
ssh admin@clab-bootcamp-ceos1

```

---

## 4. Automation with Go and Python

Your environment comes pre-configured with the necessary languages.

### 🐍 Python

Python 3.11 is installed. You can run scripts immediately:

```bash
# Example: Run a Python script
python3 scripts/backup_router.py

```

### 🐹 Go (Golang)

Go is installed and ready to use.

```bash
# Example: Run a Go program
go run tools/main.go

```

---

## 5. Stop Lab & Cleanup

When you are finished with a lab exercise, you should destroy the lab to free up resources before starting the next one.

```bash
sudo containerlab destroy -t clab-topologies/lab01-basic.yml --cleanup

```

---

## 💡 Tips & Tricks

* **Web Interfaces:** If you launch a service with a Web GUI (like SRLinux), Codespaces will detect the port and show a popup "Open in Browser" in the bottom right corner. Click it to access the GUI.
* **Timeout:** The Codespace automatically stops after **30 minutes of inactivity**. Your files are saved, but the running routers will be stopped. You will need to run `containerlab deploy` again after restarting the Codespace.
* **Extensions:** Essential VS Code extensions for Go, Python, and YAML are already pre-installed for you.

---


## 6. ! IMPORTANT ! Stop the Codespace after you are DONE for the day!
If you don't want to pay too much or make sure, that you can still use it reasonably without getting charged, STOP the Codespace Instance!

* Go to the [Codespaces](https://github.com/codespaces) page
* Click to the three dots in the line of your `Active` Codespace environment `...`
* Click on `Stop codespace` if you want to pursue further in the instance later
* Click on `Delete` if you want to destroy the instance

