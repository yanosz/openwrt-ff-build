# openwrt-ff-build
Building Freifunk-Packages using OpenWRT's Image Builder

All packages are built using shell scripts

* build-ar71xx.sh - Packages for ar71xx (Most TP-Link Models, etc.)
* build-x86.sh - Packages for x86 (Generic Target only - to be used in virtualbox, etc.).

Output-Directory: <code>./bin</code> - Included Packages:

* bird (v4, v6, luci integration)
* olsr2 (0.7.1)
* bmx6
* batman-adv, batctl  (2014.4, 2013.4)
* fastd (v17)
* batman-adv(-legacy) (2013.4)

CI-Integration
-------------------

All packages are built using jenkins

* Job: https://jenkins.ffm.freifunk.net/jenkins/view/misc/job/misc-packages/
* Deployment: https://jenkins.ffm.freifunk.net/files/packages-14.07/
