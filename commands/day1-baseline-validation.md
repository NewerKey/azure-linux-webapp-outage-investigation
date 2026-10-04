# Day 1 Baseline Validation

> Use this record before injecting incidents. Capture command output as text, redact the VM public IP and your home/admin CIDR, and do not include private keys, Terraform state, or saved plan files.

## Scope and evidence handling

This document records command-level evidence for the known-good state before controlled incidents. See the README for the project overview, architecture, deployment instructions, and future incident list; those are intentionally not duplicated here.

**Captured on:** 2026-10-04; UTC timestamps shown where available  
**Operator:** _Add name or handle_

Use text output rather than screenshots. Redact the VM public IP and administrator/home CIDR. Do not include private keys, Terraform state, or saved plan files.

## 1. Validation evidence

| Layer/check                      | Command or evidence                                               | Expected result                                                                                | Observed result                                                                                           | Pass / fail / not tested |
| -------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------ |
| Azure resource state             | Azure Portal/CLI and `terraform state list`                       | Resource group, VNet, subnet, public IP, NSG, rules, NIC, association, VM, and OS disk present | 10 Terraform state resources; VM running and provisioning succeeded                                       | Pass                     |
| SSH transport and authentication | `ssh -i ~/.ssh/id_azure_lab supportuser@<vm-public-ip>`           | Login succeeds                                                                                 | Login succeeded; host key was accepted on first connection                                                | Pass                     |
| Guest OS                         | `hostnamectl`                                                     | Ubuntu VM identity and OS reported                                                             | Ubuntu 22.04.5 LTS; `support-outage-lab-vm`                                                               | Pass                     |
| Kernel                           | `uname -r`                                                        | Running Azure Ubuntu kernel reported                                                           | `6.8.0-1064-azure`                                                                                        | Pass                     |
| System state                     | `systemctl is-system-running`                                     | `running`                                                                                      | `running`                                                                                                 | Pass                     |
| SSH service                      | `systemctl is-active ssh`                                         | `active`                                                                                       | `active`                                                                                                  | Pass                     |
| Nginx service                    | `systemctl status nginx --no-pager`                               | `active (running)` and enabled                                                                 | `active (running)`; enabled; service start observed at 2026-10-04 03:49:55 UTC                            | Pass                     |
| Nginx version                    | `nginx -v`                                                        | Version reported by installed binary                                                           | HTTP response header confirmed `nginx/1.18.0 (Ubuntu)`; explicit `nginx -v` output still needs capture    | Partial                  |
| Listener                         | `sudo ss -lntp`                                                   | Nginx listens on TCP/80; SSH listens on TCP/22                                                 | Nginx observed on `0.0.0.0:80` and `[::]:80`; SSH on port 22                                              | Pass                     |
| VM-local HTTP                    | `curl -I --max-time 5 http://localhost` on the VM                 | HTTP 200 from Nginx                                                                            | HTTP 200; `Server: nginx/1.18.0 (Ubuntu)`; content length 3420                                            | Pass                     |
| Public HTTP                      | `curl -I --max-time 5 http://<vm-public-ip>` from the workstation | HTTP 200 from Nginx                                                                            | HTTP 200; `Server: nginx/1.18.0 (Ubuntu)`; content length 3420                                            | Pass                     |
| Ansible connectivity             | `ansible web -m ping` from the control node                       | `pong`; remote Python discovered                                                               | `pong`; Python discovered at `/usr/bin/python3`                                                           | Pass                     |
| Ansible idempotency              | Run `ansible-playbook site.yml` twice                             | Second real run reports `changed=0`                                                            | First real run: `changed=2`; second real run: `changed=0`                                                 | Pass                     |
| Effective NSG rules              | Azure NIC effective security rules view/CLI                       | SSH and HTTP allow rules confirmed; no 443 allow                                               | Not independently verified; TCP probes confirm observed reachability, not the full effective-rule listing | Not tested               |

## 2. Nginx state transition

| Phase          | Service and socket evidence                                                                | HTTP evidence                                                                         |
| -------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| Before Ansible | No TCP/80 listener; `ss -lntp` showed SSH on TCP/22 and the local resolver on TCP/53       | A TCP/80 request from the workstation returned connection refused                     |
| After Ansible  | Nginx was `active (running)` and enabled; listeners appeared on `0.0.0.0:80` and `[::]:80` | VM-local and external requests returned HTTP 200 with `Server: nginx/1.18.0 (Ubuntu)` |

Connection refused is consistent with a TCP reset when no service listens, while a timeout is consistent with a silent drop. Neither result alone proves where a packet was rejected; use host and Azure-side evidence to corroborate.

## 3. Related project documentation

See `README.md` for the architecture diagram, deployment and rebuild instructions, project status, and future incident catalog. This document is limited to the baseline evidence and checks still outstanding.

## 4. Timed Rebuild

The lab was destroyed and rebuilt from the repository to measure how long recovery to a working web page takes.

| Item      | Value                                           |
| --------- | ----------------------------------------------- |
| Started   | 2026-10-04T06:29:18+02:00                       |
| Completed | 2026-10-04T06:35:29+02:00                       |
| Elapsed   | 06:10 (mm:ss), 370 s                            |
| Result    | `Public HTTP status: 200`                       |

### What the interval includes

Wall-clock time for the whole sequence, including the time spent typing between commands. It is not automation time alone.

Commands, in order (run from the repository root unless noted):

```bash
make destroy
make plan
make apply
cd ansible
terraform -chdir=../terraform output -raw ansible_inventory > inventory.ini
ansible-playbook site.yml
# HTTP check against the public IP read from the Terraform output
```

Approximate intervals between command entries, which include typing and therefore overstate each step:

| Step                          | Interval |
| ----------------------------- | -------- |
| `make destroy` to `make plan` | 108 s    |
| `make apply` to next command  | 85 s     |
| `ansible-playbook` to HTTP check | 59 s  |

### Measurement notes

- The Completed time and the elapsed figure were reconstructed from timestamped shell history (command-entry times, accurate to about a second); the original terminal printout was not captured.
- The elapsed figure is `end_epoch - start_epoch`. Those epoch values were captured 8 to 9 seconds before the two ISO timestamps above, so the span between the Started and Completed lines is 06:11.
- The only post-rebuild check recorded is HTTP 200 from the public address. Service state, listeners, and effective NSG rules were not re-verified after the rebuild.

## 5. Open items

- Capture explicit `nginx -v` output (currently inferred from the HTTP `Server` header).
- Verify the effective NSG rules from Azure (SSH and HTTP allow, no 443 allow).
- Fill in the Operator field.
