# MinIO on a Linux VM for testing. 🚀🧪



[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fderdanu%2Fazure-minio-vm%2Fmaster%2Fazuredeploy.json)

Click the button above to open the Azure Portal with this ARM template preloaded. Review parameters and settings, then follow the portal steps to deploy the resources to your subscription. ⚙️

## ⚠️ Warning — Not for production use

This ARM template is provided for testing and demonstration purposes only. It is intentionally simple and does not include production-grade hardening.

- 🔑 Default credentials are used by default; change `minioRootUser` and `minioRootPassword` at deployment time.
- 🧩 The VM is started with a Custom Script extension (no systemd service, limited resiliency).
- 🔒 TLS, backups, monitoring, and proper storage persistence are not configured.
- 🌐 The NSG opens ports to the internet; restrict source addresses for production.

Do not use this template in production without applying appropriate security and operational controls.

## 🔌 Open ports

This template configures the Network Security Group to allow the following inbound ports by default:

- 🔐 22 — SSH (access the VM)
- 🧰 9000 — MinIO server (S3-compatible API)
- 🖥️ 9001 — MinIO web console (admin UI)

For security, restrict the source address prefixes for these rules (limit to your office/public IP or a VPN) before deploying to production.
