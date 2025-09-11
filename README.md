# MinIO on a Linux VM for testing. 🚀🧪



[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fderdanu%2Fazure-minio-vm%2Fmaster%2Fazuredeploy.json)

Click the button above to open the Azure Portal with this ARM template preloaded. Review parameters and settings, then follow the portal steps to deploy the resources to your subscription. ⚙️

## ⚠️ Warning — Not for production use

This ARM template is provided for testing and demonstration purposes only. It is intentionally simple and does not include production-grade hardening.

- 🔑 Default credentials are used by default; change `minioRootUser` and `minioRootPassword` at deployment time.
- 🧩 The VM uses a systemd service for MinIO (persistent across reboots).
- 🔒 TLS, backups, monitoring, and proper storage persistence are not configured.
- 🌐 The NSG opens ports to the internet; restrict source addresses for production.

Do not use this template in production without applying appropriate security and operational controls.

## 🔌 Open ports

This template configures the Network Security Group to allow the following inbound ports by default:

- 🔐 22 — SSH (Deny by default)
- 🧰 9000 — MinIO server (S3-compatible API)
- 🖥️ 9001 — MinIO web console (admin UI)

For security, restrict the source address prefixes for these rules (limit to your office/public IP or a VPN) before deploying to production.

## 🐛 Debugging & tracing with the MinIO client (mc)

You can use the MinIO client `mc` to connect to the server and enable tracing. 

### Option 1: On the VM (Linux)

Run these commands directly on the VM via SSH:

```bash
# Download and setup MinIO client
curl -L https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o ~/minio-binaries/mc
chmod +x ~/minio-binaries/mc

# Set up alias to local MinIO instance
~/minio-binaries/mc alias set myminio http://localhost:9000 <MINIO_ROOT_USER> <MINIO_ROOT_PASSWORD>

# Start real-time tracing (useful for debugging API calls)
~/minio-binaries/mc admin trace myminio
```

### Option 2: Remote debugging (Windows client)

For remote debugging from a Windows machine, download the Windows MinIO client:

```powershell
# Download mc.exe for Windows
Invoke-WebRequest -Uri "https://dl.min.io/client/mc/release/windows-amd64/mc.exe" -OutFile "mc.exe"

# Set up alias using the public IP (replace <PUBLIC_IP> with your VM's public IP)
.\mc.exe alias set myminio http://<PUBLIC_IP>:9000 <MINIO_ROOT_USER> <MINIO_ROOT_PASSWORD>

# Start tracing
.\mc.exe admin trace myminio
```

Replace `<PUBLIC_IP>` with your VM's public IP address (available from the deployment outputs), and `<MINIO_ROOT_USER>` and `<MINIO_ROOT_PASSWORD>` with the values you provided during deployment (or the parameter defaults). Tracing will print live admin traces useful for debugging.

## ⚙️ Managing the MinIO systemd service

MinIO runs as a systemd service and can be managed using standard systemd commands:

```bash
# Check service status
sudo systemctl status minio

# Restart the service
sudo systemctl restart minio

# View real-time logs
sudo journalctl -u minio -f

# Stop the service
sudo systemctl stop minio

# Start the service
sudo systemctl start minio

# Disable auto-start on boot
sudo systemctl disable minio

# Enable auto-start on boot
sudo systemctl enable minio
```

The service configuration is located at `/etc/systemd/system/minio.service` and environment variables are in `/etc/default/minio`.

## 🔁 Redirect HTTP port 80 to MinIO (optional)

If you want MinIO API available on the standard HTTP port 80, you can add an iptables NAT rule on the VM to redirect incoming port 80 traffic to MinIO's port 9000:

```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 9000
```

Notes:
- The rule is not persistent across reboots. To make it persistent, install `iptables-persistent` or add the rule to a startup script/systemd unit.
- Exposing MinIO on port 80 over plain HTTP is insecure for production — prefer TLS and proper firewalling.

> Note: Port 80 is not opened by the template's NSG rules by default. If you add the iptables redirect and want external HTTP access on port 80, you must also add an NSG rule to allow inbound port 80 (or restrict it to specific source addresses) on Azure.
